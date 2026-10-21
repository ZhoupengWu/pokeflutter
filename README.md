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
- [Releasing](#releasing) · [Release signing](#release-signing)
- [Roadmap](#roadmap)
- [Credits](#credits) · [License](#license)

## Features

The app has five tabs: **Pokédex**, **Compare**, **Quiz**, **Team** and **Favourites**.

### Pokédex

- A grid with every Pokémon: sprite, name, number and type badges, tinted with the colour of the
  primary type. Names are shown as in the games ("Mr. Mime", "Tipo Zero"). Alternate forms (Mega,
  regional…) are included, e.g. "Charizard (Mega X)".
- **Search** by name (in English or Italian) or by number (`#25`, `25`).
- **Filters** by type (any of the 18) and by generation (I–IX), combinable, with removable chips
  showing what is active, and **four sort orders** (number or name, ascending or descending).
- A **Random** button to jump to a Pokémon you didn't think of.
- Settings (gear icon): theme (system / light / dark) and language (system / English / Italian).

### Pokémon detail

- Official artwork (with a **shiny** toggle), types, base stats as bars or as a **radar chart**,
  abilities (named in English or Italian), height and weight.
- **Pokédex entry**: category ("Mouse Pokémon"), description in English or Italian, habitat and
  legendary / mythical tags.
- **Forms**: Mega, regional, Gigantamax… of the species, as chips that open each form.
- **Type matchups**: what the Pokémon is weak to, resists and is immune to, with the damage
  multiplier (4×, 2×, ½×, ¼×, 0×) computed from its types, and a link to the **full 18 × 18
  type chart** (pan and zoom).
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

### Team

Pick up to six Pokémon (saved on the device). The tab shows which types the team is **weak to** and
**resists** (×N = how many members), and which types its own types **hit super effectively** or
leave **uncovered**. It is based on types only, not on moves.

### Favourites

Saved on the device and shown in the same grid as the Pokédex.

### Works offline

Anything you have already opened — details, Pokédex entries, evolution chains, the type index, artwork — is cached
on the device, so it is still there without a connection. Settings can also download all your
favourites in one go, show how much space the offline data uses and clear it. If the network is down the app says so
with a banner instead of showing errors.

### Looks right everywhere

Edge-to-edge system bars that follow the page colour, light and dark themes with contrast-checked
type colours, and a layout that adapts to small phones, large phones and
tablets (content is capped to a comfortable width). Held sideways, the detail page and the quiz
use two columns, and every screen is tested at the largest system font size.

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
> package name and the **same signing key**. Builds signed with the release key (see
> [Release signing](#release-signing)) always update in place. Builds signed with a debug key
> (forks, local builds without a key) differ from machine to machine, so you may have to
> uninstall the previous version first, which clears favourites, settings and records.

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
- **Data and icon.** `tool/generate_pokemon_names.py` rebuilds `assets/pokemonNames.json` from the
  PokéAPI CSV data (add a language there to get its names). `tool/generate_app_icon.py` draws the app
  icon (needs Pillow) and `dart run flutter_launcher_icons` writes the Android and iOS files; if it
  changes `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` in the Xcode project, revert
  that line.
- **Translations.** Strings live in `lib/l10n/app_en.arb` and `app_it.arb`; add every new string
  to **both**. `flutter pub get` (or `flutter gen-l10n`) regenerates the committed
  `app_localizations*.dart`.
- **Branches.** Work happens on feature branches that are merged into `dev` through pull
  requests; `dev` is merged into `main` for releases. Every pull request bumps the version in
  `pubspec.yaml`.

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

**Signing.** See [Release signing](#release-signing) below.

**Identifiers.** The Android application id is `com.wux.pokeflutter`. Change it in
`android/app/build.gradle.kts` (and the iOS bundle identifier) before publishing under your own
account.

## Release signing

Release builds are signed with a key that is **never committed**. It is read from
`android/key.properties` (local builds) or from environment variables (CI). If neither is
complete the build falls back to the debug key, so `flutter run --release` and forks keep working,
but that APK cannot update an app signed with the real key.

**1. Create the key (once) and back it up.** Keep the file and the passwords somewhere safe and
separate from the repository: if you lose the key you can no longer update the installed app.

```bash
keytool -genkeypair -v -keystore pokeflutter-release.jks -alias pokeflutter \
  -keyalg RSA -keysize 2048 -validity 10000
```

**2. Local release builds.** Put the keystore in `android/app/` (git-ignored) and create
`android/key.properties` (git-ignored):

```properties
storeFile=pokeflutter-release.jks
storePassword=…
keyAlias=pokeflutter
keyPassword=…
```

then `flutter build apk --release`. Check the signature with
`apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk`.

**3. CI.** In the repository go to *Settings → Secrets and variables → Actions* and add four
repository secrets:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | the keystore, base64-encoded: `base64 -w0 pokeflutter-release.jks` (`base64 -i … ` on macOS) |
| `ANDROID_KEYSTORE_PASSWORD` | the store password |
| `ANDROID_KEY_ALIAS` | `pokeflutter` (the alias used above) |
| `ANDROID_KEY_PASSWORD` | the key password |

From then on the CI APK is signed with the release key, and the build fails if the secrets are
set but the APK still ends up debug-signed. GitHub does not pass secrets to pull requests from
forks, so those builds stay debug-signed.

**First install with the real key.** Android refuses to update an app signed with a different
key, so on each phone the first release-signed APK needs the old one to be uninstalled (this clears
favourites, settings and records). Later updates install over the top as long as the build number
(`+N` in `pubspec.yaml`) is higher.

For Google Play, enable Play App Signing: this key then becomes the *upload* key.

## Roadmap

What is planned next (a pass on physical devices, localised Pokémon names,
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
