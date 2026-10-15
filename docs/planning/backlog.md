# Backlog

Everything left to do, by priority. Items come from project reviews (Oct 2026).
When an item is done, move it to `roadmap.md` / `todo.md` and delete it here.

## P2 — Quality and architecture
1. **Manual device pass**: the UI has only been verified in a headless web build with a faked
   PokéAPI. Check on a phone/emulator: grid colours and badges, long form names
   (`charizard-mega-x`), offline first run (grey grid + banner), airplane-mode behaviour with
   previously opened Pokémon (disk cache, cached images), status/navigation bar colours in both
   themes (edge-to-edge), hero animation, quiz timer feel, evolution layout for Eevee-like branches,
   landscape and a tablet.
2. **Navigation**: named routes or `go_router`; `IndexedStack` keeps all 4 tabs alive (memory).
3. **Localisation follow-ups**: localised Pokémon/ability/move names (PokéAPI provides many
   languages), more languages.
4. **Accessibility audit** with TalkBack/VoiceOver on a device (labels exist, quiz options and
   evolution stages are buttons; not verified on hardware). Check text scaling at 200 %.
5. **Release hygiene**: confirm/replace `applicationId` (`com.wux.pokeflutter`) before publishing;
   add an iOS build job if a macOS runner is acceptable; real release signing config.
6. **Cache management**: a "clear cache" action in Settings, optional prefetch of favourites for
   offline use, show how much space the image cache uses.
7. **Landscape polish**: the quiz and detail pages are cramped in landscape (they work, but little
   fits); consider two-column layouts there.

## P3 — New features
**High value**
- Advanced search: by ability, stat ranges, weakness (the `TypeChart` already makes "weak to X"
  cheap)
- Extended details: flavor text, category, habitat, moves, alternate forms, shiny sprites

**Medium**
- Cry audio playback (`audioplayers`)
- Team builder (6 Pokémon, type coverage and shared weaknesses — reuse `TypeChart`)
- Quiz: more modes (ability, "higher attack", type matchups), daily challenge, share result
- Compare 3–4 Pokémon; share comparison
- Favourites: notes, reordering, export/share, optional cloud sync
- Full type chart screen (18×18 matrix) reachable from the matchups section

**Polish**
- Skeleton loaders for the grid while the type index downloads, pull-to-refresh
- Home-screen widget / "Pokémon of the day" notification
- Share a Pokémon card as an image
- List view alternative
- Stat radar chart on the detail page; shiny/regular sprite toggle
- Search/visit history
- Opt-in crash reporting / analytics

## Notes for new sessions
- Checks that CI runs (run them before pushing):
  `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`.
  Running `dart format lib` without arguments on a file you didn't touch creates noise; the
  repo is formatted, so it should be a no-op.
- Cloud sandbox: `pokeapi.co` and `github.com` are blocked by the egress proxy, but
  `storage.googleapis.com`, `fonts.gstatic.com` and `pub.dev` work. The Flutter SDK can be
  downloaded from
  `https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json`
  (pick the current stable archive). Running `flutter` may rewrite `analysis_options.yaml` and
  `pubspec.lock`; check `git diff` before committing them.
- Because PokéAPI is unreachable there, tests must inject a mock `http.Client` or a fake API
  subclass (see `test/support/`).
- Don't `pkill -f http.server` (or any pattern that matches your own command line) in the sandbox
  shell: it kills the shell. Start servers with `(nohup … &)` and stop them by PID.
- To *see* the UI in the sandbox: copy the repo to a scratch folder, run
  `flutter create . --platforms web`, `flutter build web --release --no-web-resources-cdn`, serve
  `build/web` and drive it with Playwright (`/opt/pw-browsers` has Chromium), answering
  `pokeapi.co`, `raw.githubusercontent.com` with `page.route(...)` fakes. The repo itself has no web
  platform; don't commit the scaffold.
- Strings: add them to **both** `lib/l10n/app_en.arb` and `app_it.arb`; `flutter gen-l10n` (also run
  by `flutter pub get`) regenerates the committed `app_localizations*.dart`.
- `pubspec.lock`: running `flutter pub get` with a Flutter version different from the one that last
  wrote the lock rewrites SDK-pinned packages (`matcher`, `vector_math`…). Commit only the lines
  you meant to change (e.g. a new dependency).
- Don't put session links in commits or PR descriptions (user preference).
