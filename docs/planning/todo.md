# To-Do List

## ✅ Done
- Phase 1 (v1.1.0): detail page, search, navigation, random Pokémon, error handling
- Phase 2 (v1.2.0): type filter, favourites, comparison
- Phase 3 (v1.3.0): details cache, persistent favourites, quiz
- Phase 4 (v1.3.1): Android INTERNET permission, quiz type questions, type filter on the list
- Phase 5 (v1.4.0): grid without per-cell requests, typed API errors, null-safe parsing,
  shared repository, theme + bundled font, accessibility labels, tests, CI, docs
- Phase 6 (v1.5.0): dark theme + settings, IT/EN localisation, type matchups, evolution chain,
  quiz difficulty/timer/records, controllers + split pages, APK build in CI
- Phase 7 (v1.6.0): Provider services, new folder layout, offline cache, responsive layout,
  number search + generation filter + sorting, back-navigation and search-focus fixes
- Phase 8 (v1.7.0): filter/picker sheets above the navigation bar, offline data size + clear in Settings,
  README rewrite, release signing with a real key, CLAUDE.md, Pokédex entry on the detail page

## 🔲 Next
Everything left is in [`backlog.md`](backlog.md). Suggested first steps:
1. Manual pass on a device/emulator (P2-1): the UI was only checked in a headless web build.
2. Named routes / `go_router` (P2-5) and localised Pokémon names (P2-6).
3. The remaining features: extended details, team builder, cry playback, …
