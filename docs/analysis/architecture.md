# Architecture

Flutter app, version 1.5.0. Layers are folders under `lib/`. Pages render, **controllers**
(`ChangeNotifier`) hold the state and rules, and a few singletons provide data. There is no
state-management package (see `planning/backlog.md`).

## Layout

```
lib/
├── main.dart                     # entry point (see "Startup"), theme + locale from AppSettings
├── l10n/
│   ├── app_en.arb, app_it.arb    # strings (source of truth; edit these)
│   ├── app_localizations*.dart   # gen-l10n output, committed
│   ├── l10n_extensions.dart      # context.l10n, typeName(), typeList()
│   └── pokemon_labels.dart       # stat labels, evolution requirement text, number format
├── model/
│   ├── pokemon.dart              # Pokemon + PokemonStat, null-safe fromJson (keeps speciesName)
│   ├── pokemon_list_item.dart    # name + url; derives id and sprite URL
│   ├── evolution.dart            # EvolutionChain / EvolutionStage / EvolutionRequirement
│   └── quiz_model.dart           # QuizQuestion, QuizResult (scoring), QuizMode, QuizDifficulty
├── controllers/                  # state + rules, no widgets
│   ├── home_controller.dart      # list, search, type filters (waits for the type index)
│   ├── pokemon_detail_controller.dart  # details, then evolution chain (fails independently)
│   ├── compare_controller.dart   # two slots, ignores superseded loads
│   └── quiz_controller.dart      # game flow, countdown, scoring, saved records
├── utils/
│   ├── pokeapi_client.dart       # JSON GET with timeout, retry, typed PokemonApiException
│   ├── pokemon_api.dart          # /pokemon/{name}: cache-first, shares in-flight requests
│   ├── evolution_api.dart        # /pokemon-species -> /evolution-chain, cached per species
│   ├── pokemon_cache.dart        # in-memory cache of Pokemon details
│   ├── pokemon_repository.dart   # bundled list (assets/pokemonList.json), loaded once
│   ├── pokemon_type_index.dart   # name -> types (primary first), built from /type/{name}
│   ├── type_chart.dart           # static 18x18 damage multipliers (works offline)
│   ├── favourites_manager.dart   # ValueNotifier + shared_preferences
│   ├── app_settings.dart         # theme mode + language, persisted
│   ├── quiz_logic.dart, quiz_stats_store.dart  # question generation; best scores per difficulty
│   ├── theme.dart, app_colors.dart, palette.dart, contrast.dart  # themes and colours (see below)
│   ├── pokemon_constants.dart    # type -> colour map (also the list of the 18 types)
│   └── capitalize.dart
└── views/
    ├── shell_page.dart           # bottom navigation (IndexedStack; hidden tabs get TickerMode off)
    ├── home/                     # home_page, home_widgets (message, banner, filter chips)
    ├── detail/                   # page, header, about/abilities/stats, type matchups, evolution
    ├── compare/                  # page, slot cards, stats table, picker sheet
    ├── quiz/                     # page, start / question / results views, shared widgets
    ├── favourite_page.dart
    └── widgets/                  # grid_item, pokemon_list, search_bar, type_filter_sheet, settings_sheet, …
```

## Startup

`main()` switches to edge-to-edge, loads the Pokémon list through `PokemonRepository`, re-hydrates
the favourites and the settings, and starts `PokemonTypeIndex.ensureLoaded()` without waiting.
`MyApp` listens to `AppSettings` (theme mode, locale) and wraps every page in an
`AnnotatedRegion<SystemUiOverlayStyle>` so the status/navigation bars take the page colour.

## Data flow

Sources are deliberately separate so the Pokédex grid never needs one request per Pokémon:

```
assets/pokemonList.json ──> PokemonRepository ──> HomeController / Quiz / Compare / Favourites
        (name + url -> id, sprite URL)

PokéAPI /type/{18 types} ──> PokemonTypeIndex ──> GridItem (colour, badges), type filter
        (once, then shared_preferences)

PokéAPI /pokemon/{name} ──> PokemonApi ──> PokemonCache ──> Detail, Compare, Quiz
PokéAPI /pokemon-species + /evolution-chain ──> EvolutionApi ──> Detail (evolution section)
TypeChart (static) ──> Detail (type matchups)
```

- **Grid cells** (`GridItem`) are stateless: name/id/sprite from the list, types from
  `PokemonTypeIndex` (they repaint when it loads; grey until then). With a `heroScope` the
  sprite flies into the detail artwork (scope keeps tags unique: every tab stays alive).
- **Type filter** runs on the list *before* the grid is built (`HomeController.applyFilters`);
  selected types are OR-ed.
- **API errors**: `PokeApiClient` throws `PokemonApiException` (`network`, `notFound`, `server`,
  `parse`), retries network/5xx once and times out after 15 s. Screens show a Retry.
- **Detail page**: `PokemonDetailController` loads the Pokémon, then the evolution chain; the chain
  failing shows a retry in its section only. Type matchups come from `TypeChart` (no network).
- **Quiz**: `QuizController` owns the game. "Guess the type" questions start unresolved
  (`QuizQuestion.isResolved == false`) and are completed with `QuizLogic.resolveTypeQuestion` once
  the real types are fetched. Difficulty: easy = Pokédex 1–151, no timer; normal/hard = every species
  (never alternate forms), 20 s / 10 s per question. Score: 100 per correct answer + 25 per answer
  already in the streak (max four steps). The countdown pauses when the tab is hidden
  (`TickerMode`).

## Theming and colours

`AppColors` (a `ThemeExtension`) holds *roles* — `surface`, `fill`, `border`, `subtle`, `muted`,
`strong`, `onStrong` — with light and dark values; widgets use `context.colors.<role>` instead of
fixed greys. Type colours are the same in both themes; text drawn in a type colour on a page
surface goes through `ensureContrast` (contrast.dart). Theme mode (system/light/dark) and language
(system/English/Italiano) are in `AppSettings`, edited from the Settings sheet on Home.

## Localisation

`flutter gen-l10n` (config in `l10n.yaml`, runs on `flutter pub get`/`flutter run`) turns
`lib/l10n/app_*.arb` into `app_localizations*.dart`, which are committed so analysis works without a
generation step. Add a string to **both** ARB files (en is the template), then use
`context.l10n.key`. Pokémon names, ability, item and move ids are not translated (PokéAPI ids);
type names and stat labels are.

## Persistence

| What | Where | Key |
|---|---|---|
| Favourites | `shared_preferences` | `favourite_pokemon_names` (list of names) |
| Type index | `shared_preferences` | `pokemon_type_index_v2` (JSON: name -> types) |
| Settings | `shared_preferences` | `settings_theme_mode`, `settings_locale` |
| Quiz records | `shared_preferences` | `quiz_records_v1` (JSON per difficulty) |
| Pokémon details, evolution chains | memory only | – |

## Dependencies

`http`, `shared_preferences`, `flutter_screenutil` (design size 360×979), `flutter_svg`,
`flutter_localizations` + `intl`, `cupertino_icons`. Dev: `flutter_test`, `flutter_lints`.
Roboto is bundled in `assets/fonts`.

## Testing

Everything that does I/O takes an injectable collaborator (`http.Client`, asset loader, API
classes, stores), so tests use `MockClient`, fake `PokemonApi`/`EvolutionApi` subclasses
(`test/support/quiz_fakes.dart`, `detail_fakes.dart`) and in-memory `SharedPreferences`
(`setMockInitialValues`). `test/support/fixtures.dart` builds PokéAPI-shaped JSON and
`test/support/test_app.dart` wraps a widget with screen-util, theme and localisations.
Controllers are tested as plain Dart; pages get a controller injected. Widget tests set a
phone-sized `tester.view` because the layout uses `flutter_screenutil`.

Gotchas learned the hard way:
- Don't return the removed future from a `whenComplete` callback (an arrow body deadlocks).
- `Future.timeout` inside a widget test leaves a fake-clock timer pending: seed
  `SharedPreferences` with a stored type index so `HomePage` doesn't hit the network.
- `IndexedStack` does **not** disable tickers of hidden children; `ShellPage` wraps each tab in a
  `TickerMode`.
- `flutter pub get` with a different SDK than the one that wrote `pubspec.lock` rewrites the pins
  of SDK-bound packages (`matcher`, `vector_math`…); don't commit that noise.
