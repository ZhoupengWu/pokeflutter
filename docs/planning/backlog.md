# Backlog

Everything left to do, by priority. Items come from project reviews (Oct 2026).
When an item is done, move it to `roadmap.md` / `todo.md` and delete it here.

## P2 — Quality and architecture
1. **Device pass, rest of it**: the release APK has been tried on a phone (all fine except the
   favourite heart, fixed). Still to look at on hardware: a tablet, landscape (new two-column
   layouts), 200 % font size, TalkBack/VoiceOver (labels exist, quiz options and evolution stages
   are buttons; nothing audited on a device).
2. **Localisation follow-ups**: ability names are translated (EN/IT) and Pokémon get their proper
   display names from `assets/pokemonNames.json` (the Italian names are the English ones except a
   handful, e.g. "Tipo Zero"; `tool/generate_pokemon_names.py` takes more languages). Not done: move
   and item names, and more UI languages (needs the languages to be chosen and every string
   translated).
3. **Release hygiene**: release signing works (the CI APK is signed with the owner's key). Confirm or
   replace `applicationId` (`com.wux.pokeflutter`) before publishing; add an iOS build job if a
   macOS runner is acceptable; the app label stays `pokeflutter`.
4. **Navigation (decision, not work)**: the app keeps `Navigator.push`. Named routes / `go_router`
   only pay off with deep links or web URLs, which the app does not have; revisit then.

## P3 — New features
**High value**
- Advanced search by ability or stat range: needs data PokéAPI only gives one Pokémon at a time
  (the "weak to" filter is done)
- Extended details: moves (Pokédex entry, category, habitat, forms and the shiny artwork are done)

**Medium**
- Cry audio playback (`audioplayers`)
- Team builder follow-ups: suggest a Pokémon that fixes the biggest weakness; share the team
- Quiz: more modes (ability, move type), a daily-challenge reminder notification
- Compare 3–4 Pokémon; share comparison
- Favourites: notes, reordering, export/share, optional cloud sync

**Polish**
- Skeleton loaders for the grid while the type index downloads, pull-to-refresh
- Home-screen widget / "Pokémon of the day" notification
- Share a Pokémon card as an image
- List view alternative
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
