# Repository Structure

## Root Level
- `lib/`: Main application code
- `android/`: Android platform-specific code
- `ios/`: iOS platform-specific code
- `assets/`: Static assets (JSON data, icons)
- `test/`: Unit tests
- `build/`: Build outputs
- `pubspec.yaml`: Dependencies and configuration
- `analysis_options.yaml`: Code analysis settings

## lib/ Structure
```
lib/
├── main.dart                 # App entry point
├── model/
│   ├── pokemon.dart          # Pokemon data model
│   └── pokemon_list_item.dart # List item model
├── utils/
│   ├── pokemon_api.dart      # API service
│   ├── pokemon_costants.dart # Type colors
│   ├── theme.dart            # App theme
│   ├── palette.dart          # Color palette
│   └── capitalize.dart       # String extension
└── views/
    ├── homepage.dart         # Main screen
    └── widgets/
        ├── pokemon_list.dart # Grid list widget
        ├── grid_item.dart    # Individual Pokemon card
        ├── search_bar.dart   # Search interface
        ├── bottom_nav_bar.dart # Navigation bar
        ├── random_floating_button.dart # FAB
        └── styled_text.dart  # Custom text widget
```

## Organization
The project follows Flutter conventions with a simple folder structure. The `lib/` folder is organized by concern (model, utils, views) rather than by feature. Assets are stored in the `assets/` folder with type icons in subfolders.