# Technical debt

Current state; the actionable list with priorities is `planning/backlog.md`.

## Architecture
- **Singletons everywhere** (`FavouritesManager`, `PokemonCache`, `PokemonTypeIndex`,
  `PokemonApi`, `PokemonRepository`): fine for now, hard to swap in widget tests
  (`GridItem` and the API already accept injected collaborators; pages do not).
- **Large widgets** mixing loading, state and UI: `quiz_page.dart` (~560 lines),
  `compare_page.dart` (~500), `pokemon_detail_page.dart` (~370), `homepage.dart`.
- **No state management package** (`setState` only).
- **`utils/` mixes concerns** (api, theme, extensions, constants).
- **Navigation** is `Navigator.push` with no named routes / deep links; `IndexedStack`
  keeps all four tabs alive.

## Data
- **Pokémon details are cached in memory only** and sprites are not cached on disk beyond
  Flutter's default image cache.
- **Offline first run**: the grid works but is grey (no type index) until a connection is available.
- Alternate forms in `pokemonList.json` (ids > 10000) may lack sprites; the UI falls back to an icon.

## Quality
- No localisation (English strings hard-coded); accessibility covers icon-only controls but
  has not been audited with a screen reader on a device.
- `ScreenUtil` design size 360×979 has not been verified on tablets / landscape.
- CI runs format, analyze and tests; there is no build job for Android/iOS.
