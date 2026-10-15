# PokéFlutter

[![CI](https://github.com/ZhoupengWu/pokeflutter/actions/workflows/ci.yml/badge.svg)](https://github.com/ZhoupengWu/pokeflutter/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.11-0175C2?logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-lightgrey)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)

A fast, good-looking and **offline-friendly Pokédex** built with Flutter. Browse every Pokémon,
search and filter them, check what they are weak to, follow their evolution chain, compare two of
them, save your favourites and test your knowledge with a quiz — in light or dark mode, in English
or Italian.

- [Features](#features)
- [Getting started](#getting-started)
- [Install a build on your phone](#install-a-build-on-your-phone)
- [How it works](#how-it-works)
- [Development](#development)
- [Project layout](#project-layout)
- [Releasing](#releasing)
- [Roadmap](#roadmap)
- [Credits](#credits) · [License](#license)

## Features

The app has four tabs: **Pokédex**, **Compare**, **Quiz** and **Favourites**.

### Pokédex

- A grid with every Pokémon: sprite, name, number and type badges, tinted with the colour of the
  primary type. Alternate forms (Mega, regional…) are included.
- **Search** by name or by number (`#25`, `25`).
- **Filters** by type (any of the 18) and by generation (I–IX), combinable, with removable chips
  showing what is active, and **four sort orders** (number or name, ascending or descending).
- A **Random** button to jump to a Pokémon you didn't think of.
- Settings (gear icon): theme (system / light / dark) and language (system / English / Italian).

### Pokémon detail

- Official artwork, types, base stats with bars, abilities, height and weight.
- **Type matchups**: what the Pokémon is weak to, resists and is immune to, with the damage
  multiplier (4×, 2×, ½×, ¼×, 0×) computed from its types.
- **Evolution chain**: every stage, including branches such as Eevee's; tap a stage to open it.
- Favourite toggle and a back arrow that returns straight to the list, while the system back
  button steps back through the Pokémon you opened.

### Compare

Pick two Pokémon from a searchable list and compare their stats side by side, with the higher value
of each pair highlighted in green.

### Quiz

- 10 questions: **"Who's that silhouette?"** and **"What type is it?"**
- Three difficulties — *easy* (original 151, no timer), *normal* (every species, 20 s per
  question) and *hard* (every species, 10 s).
- Score: 100 points per correct answer plus a streak bonus (+25 per consecutive correct answer, up
  to +100). Your best scores are saved per difficulty.
- Options are exposed to screen readers, so the quiz is playable with TalkBack/VoiceOver.

### Favourites

Saved on the device and shown in the same grid as the Pokédex.

### Works offline

Anything you have already opened — details, evolution chains, the type index, artwork — is cached
on the device, so it is still there without a connection. If the network is down the app says so
with a banner instead of showing errors.

### Looks right everywhere

Edge-to-edge system bars that follow the page colour, light and dark themes with contrast-checked
type colours, and a layout that adapts to small phones, large phones and
tablets (content is capped to a comfortable width).

## Getting started

Requirements:

- A recent stable [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.11.1`).
- An Android emulator/device or an iOS simulator/device.
- An internet connection the first time (data and images come from the web, then they are cached).

```bash
git clone https://github.com/ZhoupengWu/pokeflutter.git
cd pokeflutter
flutter pub get      # also generates the localisation code
flutter run          # pick a device when asked
```

Build an installable Android APK:

```bash
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

## Install a build on your phone

Every push and pull request builds a release APK in CI. Open the workflow run on the
[Actions tab](https://github.com/ZhoupengWu/pokeflutter/actions/workflows/ci.yml), download the
`app-release-apk` artifact (kept for 7 days), unzip it and install `app-release.apk`.

> **Updating.** Android only installs an update over an existing app if both have the same
> package name and the **same signing key**. CI builds are currently signed with a debug key that
> is not guaranteed to be the same between runs, so you may have to uninstall the previous version
> first (this clears favourites, settings and records). See [Releasing](#releasing).

## How it works

**Data.** Pokémon data comes from [PokéAPI](https://pokeapi.co/) and sprites from the
[PokéAPI sprites repository](https://github.com/PokeAPI/sprites). The list of names ships with the
app (`assets/pokemonList.json`), so the grid appears immediately; details, evolutions and the
type index are fetched on demand.

**Caching.** Requests go through three layers: memory → a JSON file per request on disk (up to
400 entries, least recently used first, valid for 30 days) → the network. When the network fails
or PokéAPI answers with a server error, an expired disk entry is used instead of an error.
Images are cached by `cached_network_image`.

**State.** Plain Flutter, no heavy framework:

- `ChangeNotifier` controllers hold the state and rules of each screen (`HomeController`,
  `PokemonDetailController`, `CompareController`, `QuizController`);
- `AppServices` creates the services once (API clients, caches, favourites, settings, quiz
  records, network status) and exposes them with [`provider`](https://pub.dev/packages/provider);
- views only build widgets and call the controllers;
- every collaborator is injected, so tests replace them with fakes and never touch the network.

More detail in [`docs/analysis/architecture.md`](docs/analysis/architecture.md).

**Tech stack.** Flutter, Material 3, `provider`, `http`, `cached_network_image`,
`shared_preferences`, `path_provider`, `flutter_screenutil`, `flutter_svg`, Flutter's `gen-l10n`.

## Development

The same checks run in CI on every push and pull request to `main` and `dev`:

```bash
dart format --output=none --set-exit-if-changed lib test   # use `dart format lib test` to fix
flutter analyze
flutter test
```

CI also builds a release APK and verifies that the merged Android manifest declares the
`INTERNET` permission.

- **Tests.** Unit tests for controllers, caches and rules (quiz scoring, type chart, filtering)
  and widget tests for the pages. HTTP clients and API classes are injected and replaced with
  fakes; shared fakes and fixtures live in `test/support/`.
- **Translations.** Strings live in `lib/l10n/app_en.arb` and `app_it.arb`; add every new string
  to **both**. `flutter pub get` (or `flutter gen-l10n`) regenerates the committed
  `app_localizations*.dart`.
- **Branches.** Work happens on feature branches that are merged into `dev` through pull
  requests; `dev` is merged into `main` for releases.

## Project layout

```
lib/
├── main.dart              # entry point
├── app_services.dart      # creates the services once and provides them (Provider)
├── l10n/                  # translations (app_en.arb, app_it.arb) and generated code
├── model/                 # Pokemon, PokemonListItem, evolution, quiz models
├── controllers/           # state and rules of Home, Detail, Compare and Quiz (ChangeNotifier)
├── data/                  # PokéAPI clients, disk/memory caches, repository, stores, settings
├── theme/                 # themes, colours, contrast, responsive sizing
├── core/                  # constants, type chart, generations, quiz logic
└── views/                 # pages by feature (home, detail, compare, quiz, favourites), shared/
assets/                    # pokemonList.json, pokeball.svg, type icons, Roboto font
test/                      # unit and widget tests (support/ holds fakes and fixtures)
docs/                      # architecture, technical debt, roadmap, backlog
```

## Releasing

1. Bump `version` in `pubspec.yaml` (`MAJOR.MINOR.PATCH+BUILD`): update the semantic version for
   user-visible changes and **always increase the build number** (`+N`) — Android refuses to
   install an update with a lower or equal build number, and Google Play and App Store Connect
   require it to be unique.
2. Make sure the checks above pass.
3. Build with `flutter build apk --release` / `flutter build appbundle` (Android) or
   `flutter build ipa` (iOS).

**Signing.** Release builds are currently signed with the debug key
(`android/app/build.gradle.kts`). Before distributing the app to other people, create a release
keystore, configure it in Gradle (reading the passwords from a git-ignored `key.properties` or
from CI secrets) and keep a backup of it: with the same key, users can update in place; without
it they have to uninstall first. If you publish on Google Play, enable Play App Signing.

**Identifiers.** The Android application id is `com.wux.pokeflutter`. Change it in
`android/app/build.gradle.kts` (and the iOS bundle identifier) before publishing under your own
account.

## Roadmap

What is planned next (real release signing, a pass on physical devices, localised Pokémon names,
cache management, advanced search, team builder…) is in
[`docs/planning/backlog.md`](docs/planning/backlog.md); what has been done is in
[`docs/planning/roadmap.md`](docs/planning/roadmap.md).

## Credits

- Data: [PokéAPI](https://pokeapi.co/). Pokémon and Pokémon character names are trademarks of
  Nintendo, Game Freak and Creatures Inc.; this is an unofficial fan project and is not
  affiliated with them.
- Font: [Roboto](https://fonts.google.com/specimen/Roboto) (Apache License 2.0), bundled in
  `assets/fonts`.

## License

Apache License 2.0 – see [`LICENSE`](LICENSE).
