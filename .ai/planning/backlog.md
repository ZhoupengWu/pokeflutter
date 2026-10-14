# Backlog

Everything left to do, by priority. Items come from a full project review (Oct 2026).
When an item is done, move it to `roadmap.md` / `todo.md` and delete it here.

## P2 — Architecture and code quality (deliberately postponed: larger refactors)
1. **State management**: replace the singletons (`FavouritesManager`, `PokemonCache`,
   `PokemonTypeIndex`, `PokemonApi`, `PokemonRepository`) with injected providers
   (Provider/Riverpod). Pages currently use the singletons directly, which limits widget tests.
2. **Split the large widgets** that mix fetching, state and UI: `quiz_page.dart` (~560 lines),
   `compare_page.dart` (~500), `pokemon_detail_page.dart` (~370), `homepage.dart` →
   controllers/ViewModels + smaller widgets.
3. **Persistent details cache**: `PokemonCache` is memory-only and unbounded (the "LRU-style"
   comment is inaccurate). Use Hive/Isar/drift with a size limit. Add `cached_network_image` so
   sprites/artwork survive restarts.
4. **Folder structure**: split `utils/` into `data/` (api, cache, repository, type index),
   `theme/` and `core/` (extensions, constants).
5. **Navigation**: named routes or `go_router`; `IndexedStack` keeps all 4 tabs alive (memory).
6. **Localisation**: `flutter_localizations` + `intl` (strings are hard-coded in English); localised
   Pokémon names (PokéAPI provides many languages).
7. **Responsive check**: `ScreenUtil` design size is 360×979; verify tablets / landscape and use
   adaptive column counts.
8. **Accessibility audit** with TalkBack/VoiceOver on a device (labels exist on icon-only controls;
   not verified on hardware). Quiz option buttons are plain `GestureDetector`s without a button role.
9. **CI build job**: add `flutter build apk` (and iOS if a macOS runner is acceptable) so manifest
   problems such as the old missing `INTERNET` permission are caught. Confirm/replace
   `applicationId` (`com.wux.pokeflutter`) before publishing.
10. **Visual verification**: the app was never run on a device/emulator in the sessions that
    produced phases 4–5 (only unit/widget tests). Do a manual pass: grid colours, long form names
    (`charizard-mega-x`), offline first run (grey grid + banner), theme colour change
    (spinners are now slate instead of purple).

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
- Opt-in crash reporting / analytics

## Notes for new sessions
- Checks that CI runs (run them before pushing):
  `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`.
  Running `dart format lib` without arguments on a file you didn't touch creates noise; the
  repo is formatted, so it should be a no-op.
- Cloud sandbox: `pokeapi.co` and `github.com` are blocked by the egress proxy, but
  `storage.googleapis.com`, `fonts.gstatic.com` and `pub.dev` work. The Flutter SDK can be
  downloaded from
  `https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json`
  (pick the current stable archive). Running `flutter` may rewrite `analysis_options.yaml` and
  `pubspec.lock`; check `git diff` before committing them.
- Because PokéAPI is unreachable there, tests must inject a mock `http.Client`
  (see `test/pokemon_api_test.dart`, `test/pokemon_type_index_test.dart`).
