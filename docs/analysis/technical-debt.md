# Technical debt

Current state; the actionable list with priorities is `planning/backlog.md`.

## Architecture
- **Controllers are plain `ChangeNotifier`s owned by the pages** (created in `initState` from
  `context.read`). Fine at this size; Riverpod/bloc would only pay off with shared state between
  tabs (e.g. favourites in several places).
- **Navigation** is `Navigator.push` with no named routes / deep links; `IndexedStack` keeps all four
  tabs alive. The detail page can be pushed many times (evolutions); its back arrow pops to the first
  route, the system back button pops one.
- `AppServices` lives next to `main.dart` and imports a `views/` typedef (`ImageProviderFactory`).

## Data
- Details, chains and images are cached on disk, but **nothing prefetches**: only Pokémon the user
  opened work offline. There is no way to clear the cache from the app.
- **Offline first run**: the grid works but is grey (no type index) until a connection is available.
- Alternate forms in `pokemonList.json` (ids > 10000) may lack sprites; the UI falls back to an icon.
- Evolution stages are matched to the bundled list by Pokédex number, so a species whose number is
  missing from the list is shown but not tappable.

## Quality
- Only English and Italian; Pokémon names, abilities, items and moves are not translated.
- Accessibility labels exist and quiz options are buttons, but nothing has been audited with
  TalkBack/VoiceOver on a device.
- Tablet and landscape layouts were only checked in a headless browser (820×1180, 844×390); the
  quiz and detail pages in landscape are usable but cramped.
- The UI has been checked in a headless browser build with a faked PokéAPI (light/dark, both
  languages) but not on a physical device.
- CI runs format, analyze, tests and builds a release APK; iOS is not built.
- `pubspec.lock` was extended by hand (new packages only) because the cloud SDK differs from the
  maintainer's; run `flutter pub get` locally and commit the result if it changes.
