# Flutter Architecture

## Feature Organization
```
lib/
├── main.dart                        # App entry point — async init
├── model/
│   ├── pokemon.dart                 # Pokemon + PokemonStat
│   ├── pokemon_list_item.dart       # Lightweight list entry
│   └── quiz_model.dart              # QuizQuestion, QuizResult, QuizMode
├── utils/
│   ├── pokemon_api.dart             # HTTP client — cache-first
│   ├── pokemon_cache.dart           # In-memory singleton cache
│   ├── favourites_manager.dart      # ValueNotifier + shared_preferences
│   ├── quiz_logic.dart              # Question generation
│   ├── pokemon_costants.dart        # Type → Color map
│   ├── theme.dart                   # App-wide ThemeData
│   ├── palette.dart                 # Gray MaterialColor swatch
│   └── capitalize.dart              # String extension
└── views/
    ├── shell_page.dart              # Navigation shell (IndexedStack)
    ├── homepage.dart                # Pokédex grid + search + filter
    ├── pokemon_detail_page.dart     # Detail screen + favourite button
    ├── compare_page.dart            # Side-by-side stat comparison
    ├── quiz_page.dart               # 10-question quiz game
    ├── favourite_page.dart          # Saved Pokémon grid
    └── widgets/
        ├── grid_item.dart           # Card with type filter + navigation
        ├── pokemon_list.dart        # GridView wrapper
        ├── search_bar.dart          # TextField + filter badge
        ├── type_filter_sheet.dart   # Multi-select type bottom sheet
        ├── random_floating_button.dart
        └── styled_text.dart
```

## Widget Hierarchy
- `MyApp` → `ShellPage` (Stateful, manages tab index)
  - Tab 0: `HomePage` → `SearchBarWidget` + `PokemonList` → `GridItem`
  - Tab 1: `ComparePage`
  - Tab 2: `QuizPage`
  - Tab 3: `FavouritePage`
- `PokemonDetailPage` — pushed via `Navigator.push` from `GridItem` and `RandomFloatingButton`

## State Management
Still `setState` per widget. Global singletons with `ValueNotifier`:
- `FavouritesManager.instance.notifier` — listened via `ValueListenableBuilder`
- `PokemonCache.instance` — read/write, no listeners needed

## Data Flow
```
assets/pokemonList.json
    └── HomePage / ComparePage / QuizPage (load once)
            └── PokemonApi.getPokemonDetails(name)
                    └── PokemonCache.get(name)  ← hit: return immediately
                    └── http.get(url)           ← miss: fetch, cache, return
                            └── Pokemon model
                                    └── GridItem / DetailPage / CompareSlot
```

## Persistence
- **Favourites**: `shared_preferences` key `favourite_pokemon_names` (list of strings)
- **Cache**: in-memory only — cleared on app restart

## Separation of Concerns
Improved vs v1.0 but still widget-centric. API calls in `GridItem` and `ComparePage`
are the main remaining coupling. A future Riverpod refactor would extract these
into providers.