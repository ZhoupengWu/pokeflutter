# Architecture

Flutter app, version 1.6.0. Layers are folders under `lib/`. Pages render, **controllers**
(`ChangeNotifier`) hold the state and rules, and long-lived services (API clients, stores, settings)
are created once in `AppServices` and handed down with `provider`.

## Layout

```
lib/
├── main.dart                     # entry point: AppServices.production(), theme + locale from settings
├── app_services.dart             # AppServices (creates the services) + AppProviders (provides them)
├── l10n/
│   ├── app_en.arb, app_it.arb    # strings (source of truth; edit these)
│   ├── app_localizations*.dart   # gen-l10n output, committed
│   ├── l10n_extensions.dart      # context.l10n, typeName(), typeList()
│   └── pokemon_labels.dart       # stat labels, evolution requirement text, number format
├── model/
│   ├── pokemon.dart              # Pokemon + PokemonStat; fromJson (API) and toCacheJson/fromCacheJson (disk)
│   ├── pokemon_list_item.dart    # name + url; derives id and sprite URL
│   ├── evolution.dart            # EvolutionChain / EvolutionStage / EvolutionRequirement
│   ├── pokemon_species.dart      # trimmed species info (en/it entry, genus, habitat, flags)
│   └── quiz_model.dart           # QuizQuestion, QuizResult (scoring), QuizMode, QuizDifficulty
├── controllers/                  # state + rules, no widgets; collaborators are constructor arguments
│   ├── home_controller.dart      # list, search (name or number), type/generation filters, sort
│   ├── pokemon_detail_controller.dart  # details, then evolution chain (fails independently)
│   ├── compare_controller.dart   # two slots, ignores superseded loads
│   └── quiz_controller.dart      # game flow, countdown, scoring, saved records
├── data/                         # everything that talks to the network or the disk
│   ├── pokeapi_client.dart       # JSON GET: timeout, retry, typed PokemonApiException, NetworkStatus
│   ├── pokemon_api.dart          # /pokemon/{name}: memory -> disk -> network, stale copy on failure
│   ├── species_api.dart          # /pokemon-species (entry, category, habitat, chain url), same layering
│   ├── evolution_api.dart        # species -> /evolution-chain, same layering
│   ├── disk_cache.dart           # one JSON file per key, LRU, failures swallowed
│   ├── offline_storage.dart      # size of the disk cache + cached images, and a way to clear them (Settings)
│   ├── network_status.dart       # "could PokéAPI be reached last time?" (drives the offline hint)
│   ├── pokemon_cache.dart        # in-memory cache of Pokemon details
│   ├── pokemon_repository.dart   # bundled list (assets/pokemonList.json), loaded once
│   ├── pokemon_type_index.dart   # name -> types (primary first), built from /type/{name}
│   ├── favourites_manager.dart, app_settings.dart, quiz_stats_store.dart  # shared_preferences
├── theme/                        # theme.dart, app_colors.dart, palette.dart, contrast.dart, responsive.dart
├── core/                         # pokemon_constants (type colours), type_chart, pokedex (generations,
│                                 #   sort), quiz_logic, capitalize
└── views/
    ├── shell_page.dart           # bottom navigation (IndexedStack; hidden tabs get TickerMode off)
    ├── home/                     # home_page, home_widgets, filter_sheet, search_bar, settings_sheet, …
    ├── detail/                   # page, header, about/abilities/stats, type matchups, evolution
    ├── compare/                  # page, slot cards, stats table, picker sheet
    ├── quiz/                     # page, start / question / results views, shared widgets
    ├── favourites/               # favourite_page
    └── shared/                   # grid_item, pokemon_list, pokemon_image, styled_text
```

## Startup

`main()` switches to edge-to-edge, builds `AppServices.production()` and awaits `services.init()`:
the bundled list is loaded, favourites are re-hydrated from it, settings are read, and the type index
starts loading without being awaited. `MyApp` wraps everything in `AppProviders`, sizes the UI with
`designSizeFor(screen)` (see "Responsive layout") and listens to `AppSettings` (theme mode, locale);
every page sits in an `AnnotatedRegion<SystemUiOverlayStyle>` so the status/navigation bars take the
page colour.

## Dependency injection

`AppServices` owns one instance of each service (repository, `PokemonApi`, `EvolutionApi`,
`PokemonTypeIndex`, `FavouritesManager`, `AppSettings`, `QuizStatsStore`, `NetworkStatus`) plus the
`ImageProviderFactory`. `AppProviders` exposes them with `Provider`; pages call `context.read<T>()`
once to build their controller (`HomeController(repository: context.read(), …)`). There are no
`.instance` singletons: tests build `AppServices(…)` with fakes (see `test/support/test_app.dart`).
Listenable services (`PokemonTypeIndex`, `AppSettings`, `NetworkStatus`) are provided with
`InheritedProvider.value` and listened to explicitly with `ListenableBuilder`.

## Data flow

Sources are deliberately separate so the Pokédex grid never needs one request per Pokémon:

```
assets/pokemonList.json ──> PokemonRepository ──> HomeController / Quiz / Compare / Favourites
        (name + url -> id, sprite URL)

PokéAPI /type/{18 types} ──> PokemonTypeIndex ──> GridItem (colour, badges), type filter
        (once, then shared_preferences)

PokéAPI /pokemon/{name} ──> PokemonApi ──> PokemonCache (memory) + DiskCache ──> Detail, Compare, Quiz
PokéAPI /pokemon-species ──> SpeciesApi (+ DiskCache) ──> Detail (Pokédex entry) and EvolutionApi
PokéAPI /evolution-chain ──> EvolutionApi (+ DiskCache) ──> Detail (evolution section)
sprites / artwork ──> PokemonImage ──> cached_network_image (disk) ──> every screen
TypeChart (static) ──> Detail (type matchups)
```

- **Grid cells** (`GridItem`) are stateless: name/id/sprite from the list, types from
  `PokemonTypeIndex` (they repaint when it loads; grey until then). With a `heroScope` the
  sprite flies into the detail artwork (scope keeps tags unique: every tab stays alive).
- **Filters and sort** run on the list *before* the grid is built (`HomeController.applyFilters`):
  search matches the name or the Pokédex number, selected types are OR-ed, generations are OR-ed
  (alternate forms have no generation, so they are hidden while one is selected), then the sort
  order (number or name, either direction) is applied.
- **Offline use**: `PokemonApi` / `EvolutionApi` look in memory, then in the `DiskCache` (a copy under
  30 days old is used without asking the network), then fetch. If the fetch fails for lack of
  connection or a 5xx, an older disk copy is returned instead of an error. Every request reports to
  `NetworkStatus`, which Home uses to show an "offline" hint; images are cached on disk by
  `cached_network_image`. The type index and favourites already persist in `shared_preferences`.
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

## Responsive layout

`theme/responsive.dart`: `designSizeFor(screen)` derives the `flutter_screenutil` design size from
the screen's *short side*, capped at 480 dp. A normal portrait phone gets exactly 360×979 (nothing
changed there); landscape keeps the same on-screen proportions instead of squashing controls; tablets
get more room rather than bigger controls. Grids use `SliverGridDelegateWithMaxCrossAxisExtent` (more
columns when wide) and `ContentWidth` keeps tabs and the detail page within 720 dp, centred.

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
| Pokémon details (compact JSON), evolution chains | `DiskCache` files in the app support dir (`pokeapi_cache/`, 400 entries, LRU) + memory | `pokemon-{name}`, `chain-{species}` |
| Images | `cached_network_image` cache | – |

## Dependencies

`http`, `shared_preferences`, `provider`, `path_provider`, `cached_network_image`,
`flutter_screenutil`, `flutter_svg`, `flutter_localizations` + `intl`, `cupertino_icons`. Dev: `flutter_test`, `flutter_lints`.
Roboto is bundled in `assets/fonts`.

## Testing

Everything that does I/O takes an injectable collaborator (`http.Client`, asset loader, API
classes, stores), so tests use `MockClient`, fake `PokemonApi`/`EvolutionApi` subclasses
(`test/support/quiz_fakes.dart`, `detail_fakes.dart`) and in-memory `SharedPreferences`
(`setMockInitialValues`). `test/support/fixtures.dart` builds PokéAPI-shaped JSON and
`test/support/test_app.dart` wraps a widget with `AppProviders` (pass an `AppServices` with fakes),
screen-util, theme and localisations; images use a plain `NetworkImage` in tests.
Controllers are tested as plain Dart; pages either get a controller injected or build their own from
the provided fakes. Disk caches are tested against a temp directory. Widget tests set a
phone-sized `tester.view` because the layout uses `flutter_screenutil`.

Gotchas learned the hard way:
- Don't return the removed future from a `whenComplete` callback (an arrow body deadlocks).
- `Future.timeout` inside a widget test leaves a fake-clock timer pending: seed
  `SharedPreferences` with a stored type index so `HomePage` doesn't hit the network.
- `IndexedStack` does **not** disable tickers of hidden children; `ShellPage` wraps each tab in a
  `TickerMode`.
- `flutter pub get` with a different SDK than the one that wrote `pubspec.lock` rewrites the pins
  of SDK-bound packages (`matcher`, `vector_math`…); don't commit that noise.
