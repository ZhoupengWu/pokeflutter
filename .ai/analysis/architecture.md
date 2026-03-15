# Flutter Architecture

## Feature Organization
The app is organized into basic folders:
- `model/`: Data models (`Pokemon`, `PokemonListItem`)
- `utils/`: Utility functions and constants (API, theme, palette, etc.)
- `views/`: UI screens and widgets

## Widget Hierarchy
- `MyApp` (Stateless) → `MaterialApp` → `ShellPage` (Stateful)
- `ShellPage` manages the `BottomNavigationBar` + `IndexedStack` with 4 pages:
  - `HomePage` (Stateful) → `SearchBarWidget`, `PokemonList` → `GridItem` (Stateful)
  - `ComparePage` (placeholder)
  - `QuizPage` (placeholder)
  - `FavouritePage` (placeholder)
- `PokemonDetailPage` (Stateful) — pushed via `Navigator.push` from `GridItem` and `RandomFloatingButton`

## Separation Between UI and Business Logic
Limited — business logic (API calls, filtering) is still inside widgets. No dedicated service or state management layer. This is acceptable for the current scale.

## Service Layers
- `PokemonApi`: Static class for API calls (returns `null` on error)
- No repository pattern or data layer abstraction

## Data Layers
- Local JSON asset for Pokémon list
- Remote API (PokéAPI) for Pokémon details
- No local storage or caching yet