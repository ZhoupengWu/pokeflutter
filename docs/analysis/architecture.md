# Architecture

Flutter app, version 1.4.0. Layers are folders under `lib/`; state is `setState` plus a few
singletons. There is no state-management package yet (see `planning/backlog.md`).

## Layout

```
lib/
├── main.dart                     # entry point (see "Startup")
├── model/
│   ├── pokemon.dart              # Pokemon + PokemonStat, null-safe fromJson
│   ├── pokemon_list_item.dart    # name + url; derives id and sprite URL
│   └── quiz_model.dart           # QuizQuestion, QuizResult, QuizMode
├── utils/
│   ├── pokemon_repository.dart   # bundled list (assets/pokemonList.json), loaded once
│   ├── pokemon_api.dart          # PokéAPI client: typed errors, timeout, retry, request sharing
│   ├── pokemon_cache.dart        # in-memory cache of Pokemon details
│   ├── pokemon_type_index.dart   # name -> types (primary first), built from /type/{name}
│   ├── favourites_manager.dart   # ValueNotifier + shared_preferences
│   ├── quiz_logic.dart           # question generation / resolution
│   ├── pokemon_constants.dart    # type -> colour map (also the list of the 18 types)
│   ├── theme.dart, palette.dart  # ThemeData (Material 3, bundled Roboto), gray swatch
│   └── capitalize.dart           # String.capitalize()
└── views/
    ├── shell_page.dart           # bottom navigation (IndexedStack keeps tab state)
    ├── homepage.dart             # grid + search + type filter + random
    ├── pokemon_detail_page.dart  # details, favourite toggle
    ├── compare_page.dart         # two slots + stat bars
    ├── quiz_page.dart            # quiz game
    ├── favourite_page.dart       # saved Pokémon grid
    └── widgets/                  # grid_item, pokemon_list, search_bar, type_filter_sheet, …
```

## Startup

`main()` loads the Pokémon list through `PokemonRepository`, re-hydrates the favourites
(`FavouritesManager.init`) and starts `PokemonTypeIndex.ensureLoaded()` without waiting for it.

## Data flow

Two sources, deliberately separate so the Pokédex grid never needs one request per Pokémon:

```
assets/pokemonList.json ──> PokemonRepository ──> HomePage / Quiz / Compare / Favourites
        (name + url -> id, sprite URL)                       │
                                                             ▼
PokéAPI /type/{18 types} ──> PokemonTypeIndex ──> GridItem (colour, type badges), type filter
        (once, then shared_preferences)

PokéAPI /pokemon/{name} ──> PokemonApi ──> PokemonCache ──> DetailPage, Compare, Quiz
        (on demand: stats, abilities, artwork)
```

- **Grid cells** (`GridItem`) are stateless: name/id/sprite come from the list, types from
  `PokemonTypeIndex` (listens to it, so cells repaint when it loads). Until then they are grey.
- **Type filter** runs on the list *before* the grid is built (`HomePage._applyFilters`),
  using `PokemonTypeIndex.matchesAny`. Selected types are OR-ed.
- **`PokemonApi`** returns `Pokemon` or throws `PokemonApiException` (`network`, `notFound`,
  `server`, `parse`). It retries network/5xx once, times out after 15 s and shares concurrent
  requests for the same Pokémon. Screens catch the exception and show a Retry.
- **Quiz**: "guess the name" questions are complete when generated. "Guess the type" questions
  start unresolved (`QuizQuestion.isResolved == false`) and are completed with
  `QuizLogic.resolveTypeQuestion` once the Pokémon's real types are fetched.

## Persistence

| What | Where | Key |
|---|---|---|
| Favourites | `shared_preferences` | `favourite_pokemon_names` (list of names) |
| Type index | `shared_preferences` | `pokemon_type_index_v2` (JSON: name -> types) |
| Pokémon details | memory only (`PokemonCache`) | – |

## Dependencies

`http` (API), `shared_preferences` (persistence), `flutter_screenutil` (responsive sizes,
design size 360×979), `flutter_svg` (pokéball), `cupertino_icons`. Dev: `flutter_test`,
`flutter_lints`. Roboto is bundled in `assets/fonts` (no `google_fonts`).

## Testing

Everything that does I/O takes an injectable collaborator (`http.Client`, asset loader, cache),
so tests use `MockClient` and in-memory `SharedPreferences` (`setMockInitialValues`).
`test/support/fixtures.dart` builds PokéAPI-shaped JSON. Widget tests set a phone-sized
`tester.view` because the layout uses `flutter_screenutil`.

Gotchas learned the hard way:
- Don't return the removed future from a `whenComplete` callback (`_inFlight.remove(key)` in an
  arrow body deadlocks, see `PokemonApi.getPokemonDetails`).
- `Future.timeout` inside a widget test creates a fake-clock timer that is still pending when the
  test ends: seed `SharedPreferences` with a stored type index so `HomePage` doesn't hit the network.
