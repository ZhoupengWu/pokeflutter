# Flutter Architecture

## Feature Organization
The app is organized into basic folders:
- `model/`: Data models (Pokemon, PokemonListItem)
- `utils/`: Utility functions and constants (API, theme, palette, etc.)
- `views/`: UI components (homepage and widgets)

This is a simple organization without clear feature boundaries.

## Widget Hierarchy
- `MyApp` (Stateless) → `MaterialApp` → `HomePage` (Stateful)
- `HomePage` contains: `SearchBarWidget`, `PokemonList` (Stateless) → `GridItem` (Stateful)
- Other widgets: `BottomNavBar`, `RandomFloatingButton`, `StyledText`

## Separation Between UI and Business Logic
Limited separation - business logic (API calls, data parsing) is mixed within Stateful widgets like `GridItem` and `HomePage`. No dedicated service layer or state management pattern.

## Service Layers
- `PokemonApi`: Static class for API calls
- No repository pattern or data layer abstraction

## Data Layers
- Local JSON asset for Pokemon list
- Remote API for Pokemon details
- No local storage or caching implemented