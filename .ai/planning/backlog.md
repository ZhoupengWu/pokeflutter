# Backlog

Output of a full project review (Oct 2026). Items are grouped by priority and
meant to be picked up one at a time in new sessions. When an item is done, move
it to `roadmap.md` / `todo.md` and tick it here.

## Already done (v1.3.1 — "Phase 4: critical fixes")
- ✅ Android `INTERNET` permission added to `android/app/src/main/AndroidManifest.xml`
  (previously only in debug/profile manifests → release builds could not load data).
- ✅ Quiz "guess the type": options are now built from the Pokémon's real types
  (`QuizLogic.resolveTypeQuestion`, called by `QuizPage` after the fetch). Previously the
  correct type was random. Taps are ignored until the question is loaded; failed loads show Retry.
- ✅ Type filter: filtering happens on the list *before* the grid is built, using
  `lib/utils/pokemon_type_index.dart` (18 `/type/{name}` requests, persisted in
  `shared_preferences`). Removed the `SizedBox.shrink()` hack in `GridItem` that left holes.
- ✅ Grid cells are keyed by Pokémon name (`PokemonList`, `FavouritePage`), fixing cells showing
  the wrong Pokémon after search/filter/unfavourite.
- ✅ Tests: `test/quiz_logic_test.dart`, `test/pokemon_type_index_test.dart`.

## P1 — Correctness / robustness
1. **Too many API calls from the grid.** Every `GridItem` calls `PokemonApi.getPokemonDetails`
   (up to 1154 requests while scrolling; no concurrency limit, no in-flight de-duplication).
   Options: derive id + sprite URL from the list item URL (`.../pokemon/{id}/`, sprite at
   `raw.githubusercontent.com/PokeAPI/sprites/...`), and use `PokemonTypeIndex` for the type colour;
   fetch full details only on tap. Also de-duplicate in-flight requests in `PokemonApi`.
2. **Fragile `Pokemon.fromJson`** (`lib/model/pokemon.dart`): `sprites.front_default` and
   `official-artwork.front_default` can be `null` (alternate forms such as mega/gmax) → crash that
   `PokemonApi` swallows. `name` uses `species.name`, so forms show the base species name
   (use the top-level `name`). Make parsing null-safe with fallbacks. Remove duplicated
   `getListTypesFromJson`.
3. **Errors are swallowed.** `PokemonApi` returns `null` for everything (offline, 404, parse).
   Introduce a typed result/exception, timeouts and retry; add "Retry" in `GridItem` and verify the
   detail page offers one.
4. **Broken test**: `test/widget_test.dart` is still the Flutter counter template and fails.
   Replace with a real smoke test (needs `SharedPreferences.setMockInitialValues`, asset bundle,
   and an HTTP client that can be injected into `PokemonApi`).
5. **README is the Flutter template**: write description, screenshots, build/run instructions,
   PokéAPI credits.

## P2 — Code quality / architecture
6. The Pokémon list JSON is loaded and parsed 4 times (`main.dart`, `homepage.dart`,
   `quiz_page.dart`, `compare_page.dart`) → single `PokemonRepository`.
7. State management: replace singletons (`FavouritesManager.instance`, `PokemonCache.instance`,
   `PokemonTypeIndex.instance`) with injected providers (Provider/Riverpod) to make widgets testable.
8. Big widgets mixing fetch + state + UI: `quiz_page.dart` (~560 lines), `compare_page.dart` (484),
   `pokemon_detail_page.dart` (373), `homepage.dart`. Extract controllers/ViewModels and smaller widgets.
9. `PokemonCache` is memory-only and unbounded despite the "LRU-style" comment → persistent cache
   (Hive/Isar/drift) with a size limit. Add `cached_network_image` for sprites/artwork.
10. Naming/structure: `pokemon_costants.dart` → `pokemon_constants.dart`; `utils/` mixes concerns
    (api, theme, extensions) → split into `data/`, `theme/`, `core/`.
11. Lints: tighten `analysis_options.yaml` (`prefer_const_constructors`, `avoid_print`,
    `always_use_package_imports`…). Fix the 9 existing `unnecessary_underscores` infos.
12. Theme: `primarySwatch: gray` conflicts with `ColorScheme.fromSeed(deepPurple)`; set
    `useMaterial3` explicitly; bundle the Roboto font instead of `google_fonts` network download.
13. Accessibility & i18n: `Semantics`/tooltips on icon buttons, `flutter_localizations` + `intl`,
    check `ScreenUtil` (designSize 360×979) on tablets/landscape.
14. Navigation: named routes / `go_router`; `IndexedStack` keeps all 4 tabs alive (memory).
15. CI: add `.github/workflows` running `flutter analyze` + `flutter test`. Version/build number
    policy in `pubspec.yaml`; confirm `applicationId` (`com.wux.pokeflutter`) before publishing.
16. `.ai/analysis/*` docs are partly stale (e.g. `technical-debt.md` lists search/navigation as
    missing). Refresh or delete.

## P3 — New features
**High value**
- Offline mode (persistent cache + connectivity indicator)
- Evolution chain on the detail page
- Type effectiveness (weaknesses/resistances/immunities) — also fulfils the Home subtitle promise
- Advanced search: by ability, Pokédex number, stat ranges, generation; sorting
- Dark mode

**Medium**
- Extended details: flavor text, category, habitat, moves, alternate forms, shiny sprites
- Cry audio playback (`audioplayers`)
- Generation filter / alphabetical index
- Team builder (6 Pokémon, type coverage and shared weaknesses)
- Quiz: difficulty levels, timer, streaks, saved high scores, more modes (ability, "higher attack")
- Compare 3–4 Pokémon; share comparison
- Favourites: notes, reordering, export/share, optional cloud sync

**Polish**
- Hero animations, skeleton loaders, pull-to-refresh
- Home-screen widget / "Pokémon of the day" notification
- Share a Pokémon card as an image
- List view alternative + adaptive columns on tablets
- Search/visit history
- Localised Pokémon names (PokéAPI has many languages)
- Opt-in crash reporting / analytics

## Notes for new sessions
- Cloud sandbox: `pokeapi.co` and `github.com` are blocked by the egress proxy, but
  `storage.googleapis.com` and `pub.dev` work. The Flutter SDK can be downloaded from
  `https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json` (pick the
  current stable archive). Running `flutter` rewrites `analysis_options.yaml` and `pubspec.lock`
  — revert those if the change is unintended. Since PokéAPI is unreachable, tests must inject a
  mock `http.Client` (see `test/pokemon_type_index_test.dart`).
- `dart format lib` reformats unrelated files in this repo; format only the files you touch.
