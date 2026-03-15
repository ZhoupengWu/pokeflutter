# To-Do List

This is a prioritized list of missing or incomplete features in the PokéFlutter app.

## 🔴 High Priority

### ✅ Pokemon Detail Page
- **Description**: Detail screen with image, types, stats, abilities, height, weight
- **Priority**: high
- **Complexity**: medium
- **Status**: DONE — `lib/views/pokemon_detail_page.dart`

### ✅ Search Functionality
- **Description**: Real-time filtering by Pokémon name via search bar
- **Priority**: high
- **Complexity**: small
- **Status**: DONE — `lib/views/widgets/search_bar.dart`, `lib/views/homepage.dart`

### ✅ Navigation System
- **Description**: Bottom navigation with IndexedStack across Home, Compare, Quiz, Favourite
- **Priority**: high
- **Complexity**: medium
- **Status**: DONE — `lib/views/shell_page.dart` + placeholder pages

### ✅ Random Pokemon Button
- **Description**: Navigates to a random Pokémon detail page
- **Priority**: high
- **Complexity**: small
- **Status**: DONE — wired in `homepage.dart`, `random_floating_button.dart`

### ✅ Error Handling
- **Description**: API errors handled gracefully with retry in detail page and null-safe grid items
- **Priority**: high
- **Complexity**: small
- **Status**: DONE — `lib/utils/pokemon_api.dart`, `grid_item.dart`, `pokemon_detail_page.dart`

## 🟡 Medium Priority

### Filter Functionality
- **Description**: Add type-based filtering for the Pokémon list via the filter button
- **Priority**: medium
- **Complexity**: medium
- **Files**: Modify `lib/views/widgets/search_bar.dart`, `lib/views/homepage.dart`, new `lib/views/widgets/type_filter_dialog.dart`

## 🟢 Low Priority

### Pokemon Comparison Feature
- **Description**: Allow comparing two Pokémon side by side
- **Priority**: low
- **Complexity**: large
- **Files**: `lib/views/compare_page.dart`, `lib/model/comparison_model.dart`

### Quiz Feature
- **Description**: Implement a Pokémon quiz game
- **Priority**: low
- **Complexity**: large
- **Files**: `lib/views/quiz_page.dart`, `lib/model/quiz_model.dart`, `lib/utils/quiz_logic.dart`

### Favourites System
- **Description**: Allow users to mark and view favourite Pokémon with local persistence
- **Priority**: low
- **Complexity**: medium
- **Files**: `lib/views/favourite_page.dart`, add local storage, modify `lib/model/pokemon.dart`

### Caching System
- **Description**: Local caching for Pokémon data to reduce API calls
- **Priority**: low
- **Complexity**: medium
- **Files**: `lib/utils/cache_manager.dart`, modify `lib/utils/pokemon_api.dart`

### State Management Refactor
- **Description**: Replace setState with Provider or Riverpod
- **Priority**: low
- **Complexity**: large
- **Files**: All stateful widgets