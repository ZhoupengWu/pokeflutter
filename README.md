# PokéFlutter

[![CI](https://github.com/ZhoupengWu/pokeflutter/actions/workflows/ci.yml/badge.svg)](https://github.com/ZhoupengWu/pokeflutter/actions/workflows/ci.yml)

A Pokédex built with Flutter. Browse all Pokémon, search and filter them by type,
see their stats, compare two Pokémon, save favourites and test your knowledge
with a quiz.

## Features

- **Pokédex** – grid of every Pokémon (name, number, sprite, type badges, colour by
  primary type), live search (by name or number), filters by type and generation, four sort
  orders and a *Random* button.
- **Detail page** – artwork, types, base stats, abilities, height and weight, **type matchups**
  (weaknesses, resistances, immunities) and the **evolution chain** (tap a stage to open it).
- **Compare** – pick two Pokémon and compare their stats side by side.
- **Quiz** – 10 questions ("who's that silhouette?" / "what type is it?") with three difficulty
  levels (the harder ones are timed), streak bonuses and saved best scores.
- **Favourites** – saved on the device.
- **Works offline** for Pokémon you have already opened (details, evolutions and images are cached).
- **Dark theme** and **English / Italian** – both follow the system by default and can be set from
  the settings (gear icon on the Pokédex tab).

Data comes from [PokéAPI](https://pokeapi.co/); sprites from the
[PokéAPI sprites repository](https://github.com/PokeAPI/sprites).

## Getting started

Requirements: a recent stable [Flutter SDK](https://docs.flutter.dev/get-started/install)
(Dart `^3.11.1`) and an internet connection (details and images are loaded from the web).

```bash
flutter pub get   # also generates the localisation code
flutter run
```

### Checks

The same checks run in CI on every push and pull request to `main` and `dev` (CI also builds a
release APK):

```bash
dart format --output=none --set-exit-if-changed lib test   # use `dart format lib test` to fix
flutter analyze
flutter test
```

Tests never touch the network: HTTP clients and API classes are injected and replaced with fakes.

Strings live in `lib/l10n/app_en.arb` and `app_it.arb`; add new ones to both.

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
test/                      # unit and widget tests
```

How the pieces fit together is described in [`docs/analysis/architecture.md`](docs/analysis/architecture.md);
what is planned next is in [`docs/planning/backlog.md`](docs/planning/backlog.md).

## Releasing

1. Bump `version` in `pubspec.yaml` (`MAJOR.MINOR.PATCH+BUILD`): update the semantic
   version for user-visible changes and **always increase the build number** (`+N`),
   which Google Play and App Store Connect require to be unique.
2. Make sure the checks above pass.
3. Build with `flutter build appbundle` (Android) or `flutter build ipa` (iOS).

> The Android application id is currently `com.wux.pokeflutter`. Change it in
> `android/app/build.gradle.kts` (and the iOS bundle identifier) before publishing
> under your own account.

## Credits

- Data: [PokéAPI](https://pokeapi.co/). Pokémon and Pokémon character names are
  trademarks of Nintendo, Game Freak and Creatures Inc.; this is an unofficial fan project.
- Font: [Roboto](https://fonts.google.com/specimen/Roboto) (Apache License 2.0), bundled in `assets/fonts`.

## License

Apache License 2.0 – see [`LICENSE`](LICENSE).
