# Development Roadmap

## ✅ Phase 1: Core Functionality — COMPLETE (v1.1.0)
**Goal**: Make the app functional with basic Pokédex features.

### Completed
- ✅ Search Functionality — real-time name filter
- ✅ Pokemon Detail Page — image, types, stats, abilities, height, weight
- ✅ Navigation System — `ShellPage` with `IndexedStack`, 4 tabs
- ✅ Random Pokemon Button — navigates to random detail page
- ✅ Error Handling — API errors handled, retry button on detail page

### Files introduced
- `lib/views/shell_page.dart` — NEW
- `lib/views/pokemon_detail_page.dart` — NEW
- `lib/views/homepage.dart` — updated
- `lib/views/widgets/search_bar.dart` — updated
- `lib/views/widgets/grid_item.dart` — updated
- `lib/views/widgets/random_floating_button.dart` — updated
- `lib/utils/pokemon_api.dart` — updated
- `lib/model/pokemon.dart` — extended with stats + abilities
- `pubspec.yaml` — version `1.1.0`, package `com.wux.pokeflutter`
- `lib/main.dart` — updated

---

## ✅ Phase 2: Advanced Features — COMPLETE (v1.2.0)
**Goal**: Add interactive features that enhance the user experience.

### Completed
- ✅ Filter Functionality — type-based multi-select filter with badge + active chips row
- ✅ Favourites System — in-memory `FavouritesManager` with `ValueNotifier`, heart button on detail page
- ✅ Pokemon Comparison — side-by-side stat bars with picker bottom sheet

### Files introduced
- `lib/views/widgets/type_filter_sheet.dart` — NEW
- `lib/utils/favourites_manager.dart` — NEW
- `lib/views/compare_page.dart` — full implementation (was placeholder)
- `lib/views/favourite_page.dart` — full implementation (was placeholder)
- `lib/views/pokemon_detail_page.dart` — added favourite button
- `lib/views/homepage.dart` — added filter logic + active chips
- `lib/views/widgets/search_bar.dart` — added filter badge + `onFilterTap`
- `lib/views/widgets/grid_item.dart` — added type filter visibility
- `lib/views/widgets/pokemon_list.dart` — passes `activeTypeFilters` down

### Also generated (complete project set)
- `lib/utils/palette.dart`
- `lib/utils/pokemon_costants.dart`
- `lib/utils/capitalize.dart`
- `lib/utils/theme.dart`
- `lib/views/widgets/styled_text.dart`
- `lib/model/pokemon_list_item.dart`
- `lib/model/pokemon.dart`

---

## 🔲 Phase 3: Polish and Optimization
**Goal**: Optimize performance and improve code quality.

### Pending
- Caching System — in-memory + optional `shared_preferences` persistence
- Persistent Favourites — save/load favourites across app restarts
- Quiz Feature — guess the Pokémon from sprite or silhouette
- State Management Refactor — Provider / Riverpod

### Dependencies
- Phase 1 ✅ and Phase 2 ✅ complete