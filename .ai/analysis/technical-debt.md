# Technical Debt

## Identified Issues
- **Mixed UI and Business Logic**: API calls and data processing happen directly in widgets (`GridItem`, `HomePage`)
- **No State Management**: Uses basic `setState` which can lead to complex state handling
- **Incomplete Features**: Search bar, navigation, and random button are UI-only without functionality
- **No Error Handling**: API calls lack proper error handling and loading states
- **Hardcoded Values**: Some styling and layout values are hardcoded
- **No Caching**: Pokemon details are fetched on every grid item creation

## Large Widgets
- `GridItem` handles both UI rendering and data fetching
- `HomePage` manages list loading and UI layout

## Tight Coupling
- Widgets directly depend on API services
- No abstraction layers between UI and data

## Unclear Module Boundaries
- Utils folder mixes different concerns (API, theming, extensions)
- No clear separation between presentation and domain logic