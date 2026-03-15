# To-Do List

This is a prioritized list of missing or incomplete features in the PokéFlutter app.

## ✅ Completed — Phase 1 (v1.1.0)

- ✅ **Pokemon Detail Page** — `lib/views/pokemon_detail_page.dart`
- ✅ **Search Functionality** — `lib/views/widgets/search_bar.dart`, `lib/views/homepage.dart`
- ✅ **Navigation System** — `lib/views/shell_page.dart`
- ✅ **Random Pokemon Button** — `lib/views/widgets/random_floating_button.dart`
- ✅ **Error Handling** — `lib/utils/pokemon_api.dart`, `grid_item.dart`, `pokemon_detail_page.dart`

## ✅ Completed — Phase 2 (v1.2.0)

- ✅ **Filter Functionality** — `lib/views/widgets/type_filter_sheet.dart`, `search_bar.dart`, `homepage.dart`, `grid_item.dart`
- ✅ **Favourites System** — `lib/utils/favourites_manager.dart`, `lib/views/favourite_page.dart`, `pokemon_detail_page.dart`
- ✅ **Pokemon Comparison** — `lib/views/compare_page.dart`

## 🟢 Low Priority — Phase 3

### Quiz Feature
- **Description**: Implement a Pokémon quiz game (guess the Pokémon from the sprite or stats)
- **Priority**: low
- **Complexity**: large
- **Files**: `lib/views/quiz_page.dart`, `lib/model/quiz_model.dart`, `lib/utils/quiz_logic.dart`

### Caching System
- **Description**: Local caching for Pokémon data to reduce repeated API calls
- **Priority**: low
- **Complexity**: medium
- **Files**: `lib/utils/cache_manager.dart`, modify `lib/utils/pokemon_api.dart`

### Persistent Favourites
- **Description**: Persist favourites across app restarts using `shared_preferences` or `Hive`
- **Priority**: low
- **Complexity**: small
- **Files**: Modify `lib/utils/favourites_manager.dart`, add `shared_preferences` to `pubspec.yaml`

### State Management Refactor
- **Description**: Replace `setState` with Provider or Riverpod for cleaner state flow
- **Priority**: low
- **Complexity**: large
- **Files**: All stateful widgets