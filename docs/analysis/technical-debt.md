# Technical debt

Current state; the actionable list with priorities is `planning/backlog.md`.

## Architecture
- **Singletons** (`FavouritesManager`, `PokemonCache`, `PokemonTypeIndex`, `PokemonApi`,
  `EvolutionApi`, `PokemonRepository`, `AppSettings`, `QuizStatsStore`). Controllers and pages take
  injected collaborators with the singleton as default, which is enough for tests; a DI/state
  package would remove the defaults. `HomePage`, `GridItem` and `FavouritePage` still reach for
  `PokemonTypeIndex.instance` / `FavouritesManager.instance` directly.
- **No state-management package**: controllers are plain `ChangeNotifier`s owned by the pages.
- **`utils/` mixes concerns** (api, theme, extensions, constants).
- **Navigation** is `Navigator.push` with no named routes / deep links; `IndexedStack`
  keeps all four tabs alive.
- `favourite_page.dart` and the widgets in `views/widgets/` are not split into feature folders yet.

## Data
- **Pokémon details and evolution chains are cached in memory only**; images are not cached on
  disk beyond Flutter's default image cache.
- **Offline first run**: the grid works but is grey (no type index) until a connection is available.
- Alternate forms in `pokemonList.json` (ids > 10000) may lack sprites; the UI falls back to an icon.
- Evolution stages are matched to the bundled list by Pokédex number, so a species whose number is
  missing from the list is shown but not tappable.

## Quality
- Only English and Italian; Pokémon names, abilities, items and moves are not translated.
- Accessibility labels exist and quiz options are buttons, but nothing has been audited with
  TalkBack/VoiceOver on a device.
- `ScreenUtil` design size 360×979 has not been verified on tablets / landscape.
- The UI has been checked in a headless browser build with a faked PokéAPI (light/dark, both
  languages) but not on a physical device.
- CI runs format, analyze, tests and builds a release APK; iOS is not built.
