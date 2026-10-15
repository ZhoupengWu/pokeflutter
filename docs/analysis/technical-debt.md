# Technical debt

Current state; the actionable list with priorities is `planning/backlog.md`.

## Architecture
- **Controllers are plain `ChangeNotifier`s owned by the pages** (created in `initState` from
  `context.read`). Fine at this size; Riverpod/bloc would only pay off with shared state between
  tabs (e.g. favourites in several places).
- **Navigation** is `Navigator.push` with no named routes / deep links (nothing needs them yet);
  `IndexedStack` keeps the tabs alive once visited. The detail page can be pushed many times (evolutions); its back arrow pops to the first
  route, the system back button pops one.
- `AppServices` lives next to `main.dart` and imports a `views/` typedef (`ImageProviderFactory`).

## Data
- Details, species, chains, ability names and images are cached on disk. Only Pokémon the user
  opened or saved from Settings ("Save favourites for offline use") work offline; the cache can be
  measured and cleared from Settings.
- **Offline first run**: the grid works but is grey (no type index) until a connection is available.
- Alternate forms in `pokemonList.json` (ids > 10000) may lack sprites; the UI falls back to an icon.
- Evolution stages are matched to the bundled list by Pokédex number, so a species whose number is
  missing from the list is shown but not tappable.

## Quality
- Only English and Italian; ability names are translated, Pokémon, item and move names are not.
- Accessibility labels exist and quiz options are buttons, but nothing has been audited with
  TalkBack/VoiceOver on a device.
- Tablet and landscape layouts were only checked in a headless browser (820×1180, 844×390); the
  detail page and the quiz use two columns when sideways. 200 % font size is covered by a widget
  test (`text_scale_test.dart`), not checked on a device.
- The release APK has been tried on a phone by the maintainer; the rest of the UI has been checked
  in a headless browser build with a faked PokéAPI (light/dark, both languages).
- CI runs format, analyze, tests and builds a release APK; iOS is not built.
- `pubspec.lock` was extended by hand (new packages only) because the cloud SDK differs from the
  maintainer's; run `flutter pub get` locally and commit the result if it changes.
