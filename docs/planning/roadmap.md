# Development Roadmap

## ✅ Phase 1 — Core Functionality (v1.1.0)
Search, Detail Page, Navigation, Random Button, Error Handling.

## ✅ Phase 2 — Advanced Features (v1.2.0)
Type Filter, Favourites System, Pokémon Comparison.

## ✅ Phase 3 — Polish & Optimization (v1.3.0)
- In-memory details cache (`PokemonCache`, cache-first `PokemonApi`)
- Persistent favourites (`shared_preferences`)
- Quiz (10 questions: silhouette → name, name → type)

## ✅ Phase 4 — Critical fixes (v1.3.1)
- Android `INTERNET` permission in the main manifest (release builds could not load data)
- Quiz "guess the type" uses the Pokémon's real types
- Type filter applied to the list before the grid is built; grid cells keyed by Pokémon name

## ✅ Phase 5 — Robustness, performance and tooling (v1.4.0)
- **Grid without per-cell API calls**: id and sprite come from the list, types from
  `PokemonTypeIndex` (18 requests, persisted, primary type first). Previously up to 1154 requests.
- **Typed API errors** (`PokemonApiException`), 15 s timeout, one retry, shared in-flight requests;
  retry buttons in the compare slots, quiz and detail page. Fixes a crash on failed detail loads.
- **Null-safe `Pokemon.fromJson`**; the name is the variety's (a mega form no longer overwrites the
  base form in the cache).
- **`PokemonRepository`**: the bundled list is parsed once instead of four times.
- **Theme**: Material 3, colour scheme from the gray palette, Roboto bundled (dropped `google_fonts`).
- **Accessibility**: tooltips/semantics on icon-only controls.
- **Tooling**: stricter lints, `pokemon_constants.dart` rename, removed dead code, real tests
  (replaced the failing counter template), GitHub Actions CI (format, analyze, test),
  new README, refreshed `docs/` docs.

## ✅ Phase 6 — Design, features and structure (v1.5.0)
- **Dark theme** and semantic colours (`AppColors`); the status and navigation bars take the page
  colour (edge-to-edge); Settings sheet (theme mode, language).
- **Italian / English** localisation (gen-l10n), including type names and screen-reader labels.
- **Type matchups** (weaknesses, resistances, immunities) and **evolution chain** on the detail
  page; hero animation from the grid; section colours kept readable on both themes.
- **Quiz**: difficulty levels, per-question timer, streaks and points, saved records, feedback after
  each answer, options exposed as buttons to screen readers.
- **Structure**: controllers for Home, Detail, Compare and Quiz; the large pages are split into
  widgets under `views/home|detail|compare|quiz`; shared `PokeApiClient`.
- **Compare**: Total row. **Home**: subtitle no longer promises searches the app does not have.
- **CI**: release APK build job that also checks the merged manifest for `INTERNET`.
- Documentation moved from `.ai/` to `docs/`.

## ✅ Phase 7 — Services, offline and layout (v1.6.0)
- **Detail page**: the in-page back arrow returns straight to the tabs after following evolutions;
  the system back button still steps back one Pokémon.
- **Search field** drops its focus when tapping elsewhere or scrolling the grid.
- **Services via Provider** (`AppServices` / `AppProviders`); singletons removed.
- **Folders**: `utils/` split into `data/`, `theme/`, `core/`; views grouped by feature.
- **Offline use**: details and evolution chains on disk (30-day freshness, stale copy on failure),
  images cached by `cached_network_image`, offline hint on Home.
- **Responsive**: design size from the short side (landscape and tablets), adaptive grid columns,
  content width cap.
- **Search and filters**: Pokédex number search, generation filter, four sort orders.

## ✅ Phase 8 — Polish, storage and release (v1.7.0)
- **Sheets** (filter, Pokémon picker) keep their content above the Android navigation bar.
- **Settings**: shows the space used by the offline data and can clear it (`OfflineStorage`).
- **README** rewritten.
- **Release signing** with a real key (`key.properties` / CI secrets), `CLAUDE.md` with the
  project conventions, version bumped in every PR.
- **Pokédex entry** on the detail page (EN/IT description, category, habitat, legendary/mythical).

## ✅ Phase 9 — P2 backlog (v1.8.0)
- **Favourite heart** on a white disc: visible on red Pokémon.
- **Tabs** other than Home are built on first visit (IndexedStack kept afterwards).
- **Ability names** in English / Italian (`AbilityApi`); `CachedResource` shares the
  memory → disk → network → stale-copy logic of the species, evolution and ability services.
- **Offline**: Settings can download the favourites (details, species, chain, abilities, images).
- **Large fonts**: grid cells grow, quiz screens scroll; a test renders every screen at 200 %.
- **Landscape**: detail page, quiz start and quiz question use two columns.

See [`backlog.md`](backlog.md) for what is next.
