# Developer Onboarding Guide

## Key Files to Read First
1. `lib/main.dart` - App entry point and theme setup
2. `lib/views/homepage.dart` - Main screen structure
3. `lib/model/pokemon.dart` - Core data models
4. `lib/utils/pokemon_api.dart` - API integration

## Most Important Modules
- **Data Layer**: `model/` and `utils/pokemon_api.dart` - understand data structures and API calls
- **UI Layer**: `views/homepage.dart` and `views/widgets/` - main interface components
- **Configuration**: `pubspec.yaml` and `lib/utils/theme.dart` - dependencies and styling

## Files to Ignore Initially
- `test/widget_test.dart` - basic test boilerplate
- Platform-specific folders (`android/`, `ios/`) - unless working on platform integration
- `build/` - generated build artifacts

## Architecture Understanding
Start with the data flow: `HomePage` loads JSON → displays `PokemonList` → each `GridItem` fetches details from API. The app uses basic Flutter patterns without advanced state management.

## Development Setup
1. Ensure Flutter SDK is installed
2. Run `flutter pub get` to install dependencies
3. Use `flutter run` to start the app
4. The app requires internet connection for Pokemon images and details