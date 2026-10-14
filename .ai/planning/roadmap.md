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
  new README, refreshed `.ai/` docs.

See [`backlog.md`](backlog.md) for what is next.
