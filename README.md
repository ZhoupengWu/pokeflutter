# PokéFlutter

[![CI](https://github.com/ZhoupengWu/pokeflutter/actions/workflows/ci.yml/badge.svg)](https://github.com/ZhoupengWu/pokeflutter/actions/workflows/ci.yml)

A Pokédex built with Flutter. Browse all Pokémon, search and filter them by type,
see their stats, compare two Pokémon, save favourites and test your knowledge
with a quiz.

## Features

- **Pokédex** – grid of every Pokémon (name, number, sprite, type badges, colour by
  primary type), live search, multi-type filter and a *Random* button.
- **Detail page** – artwork, types, base stats, abilities, height and weight.
- **Compare** – pick two Pokémon and compare their stats side by side.
- **Quiz** – 10 questions, alternating "who's that silhouette?" and "what type is it?".
- **Favourites** – saved on the device.

Data comes from [PokéAPI](https://pokeapi.co/); sprites from the
[PokéAPI sprites repository](https://github.com/PokeAPI/sprites).

## Getting started

Requirements: a recent stable [Flutter SDK](https://docs.flutter.dev/get-started/install)
(Dart `^3.11.1`) and an internet connection (details and images are loaded from the web).

```bash
flutter pub get
flutter run
```

### Checks

The same three checks run in CI on every push and pull request to `main` and `dev`:

```bash
dart format --output=none --set-exit-if-changed lib test   # use `dart format lib test` to fix
flutter analyze
flutter test
```

Tests never touch the network: HTTP clients are injected and replaced with fakes.

## Project layout

```
lib/
├── main.dart              # entry point: loads the list and favourites, warms up the type index
├── model/                 # Pokemon, PokemonListItem, quiz models
├── utils/                 # API client, cache, repository, type index, favourites, theme…
└── views/                 # pages (home, detail, compare, quiz, favourites) and widgets/
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
