# To-Do List

This is a prioritized list of missing or incomplete features in the PokéFlutter app.

## 🔴 High Priority

### Pokemon Detail Page
- **Description**: Create a detail screen showing full Pokemon information (stats, abilities, evolution, etc.)
- **Priority**: high
- **Complexity**: medium
- **Files**: `lib/views/pokemon_detail.dart`, `lib/model/pokemon_detail.dart`, modify `lib/views/widgets/grid_item.dart` for navigation

### Search Functionality
- **Description**: Implement search by Pokemon name in the search bar
- **Priority**: high
- **Complexity**: small
- **Files**: Modify `lib/views/homepage.dart`, `lib/views/widgets/search_bar.dart`

### Navigation System
- **Description**: Implement bottom navigation to switch between Home, Compare, Quiz, Favourite screens
- **Priority**: high
- **Complexity**: medium
- **Files**: `lib/views/compare_page.dart`, `lib/views/quiz_page.dart`, `lib/views/favourite_page.dart`, modify `lib/views/homepage.dart`, `lib/views/widgets/bottom_nav_bar.dart`

## 🟡 Medium Priority

### Random Pokemon Button
- **Description**: Implement random Pokemon selection and navigation to detail page
- **Priority**: medium
- **Complexity**: small
- **Files**: Modify `lib/views/widgets/random_floating_button.dart`, `lib/views/homepage.dart`

### Filter Functionality
- **Description**: Add type-based filtering for the Pokemon list
- **Priority**: medium
- **Complexity**: medium
- **Files**: Modify `lib/views/widgets/search_bar.dart`, `lib/views/homepage.dart`, add filter state management

### Error Handling
- **Description**: Add proper error handling for API calls and loading states
- **Priority**: medium
- **Complexity**: small
- **Files**: Modify `lib/utils/pokemon_api.dart`, `lib/views/widgets/grid_item.dart`, `lib/views/homepage.dart`

## 🟢 Low Priority

### Pokemon Comparison Feature
- **Description**: Allow comparing two Pokemon side by side
- **Priority**: low
- **Complexity**: large
- **Files**: `lib/views/compare_page.dart`, `lib/model/comparison_model.dart`, add selection state

### Quiz Feature
- **Description**: Implement a Pokemon quiz game
- **Priority**: low
- **Complexity**: large
- **Files**: `lib/views/quiz_page.dart`, `lib/model/quiz_model.dart`, `lib/utils/quiz_logic.dart`

### Favourites System
- **Description**: Allow users to mark and view favourite Pokemon
- **Priority**: low
- **Complexity**: medium
- **Files**: `lib/views/favourite_page.dart`, add local storage, modify `lib/model/pokemon.dart`

### Caching System
- **Description**: Implement local caching for Pokemon data to reduce API calls
- **Priority**: low
- **Complexity**: medium
- **Files**: `lib/utils/cache_manager.dart`, modify `lib/utils/pokemon_api.dart`

### State Management Refactor
- **Description**: Replace setState with a proper state management solution (Provider/Riverpod)
- **Priority**: low
- **Complexity**: large
- **Files**: Add state management package, refactor `lib/views/homepage.dart`, `lib/views/widgets/grid_item.dart`