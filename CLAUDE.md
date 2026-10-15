# PokéFlutter — notes for Claude

Flutter Pokédex (Android/iOS). Data from PokéAPI. Read `README.md` for the features and
`docs/analysis/architecture.md` for how the code fits together. What is planned is in
`docs/planning/backlog.md`.

## Working agreements
- **Talk to the user in Italian**; code, comments, docs, commits and PRs are in English.
- Work on the branch the session names. When its PR has been merged, restart the branch from the
  latest `origin/dev` (`git fetch origin dev && git checkout -B <branch> origin/dev`) and push with
  `--force-with-lease`. Open the PR **to `dev`**, ready for review (not draft).
- Several small, focused commits per PR, each with a message that says *why*.
- **Bump the version in `pubspec.yaml` in every PR** (`MAJOR.MINOR.PATCH+BUILD`): the build number
  `+N` always increases by one; fixes bump PATCH, features bump MINOR. Mention it in the README
  if it shows the version.
- **Never put the Claude Code session link in commit messages or PR descriptions.** Do not add
  attribution lines either.
- Update `docs/planning/{roadmap,backlog,todo}.md` (and `docs/analysis/*` when the architecture
  changes) in the same PR as the work. Move finished items out of the backlog.
- When in doubt about product decisions, ask the user; otherwise pick the sensible default and say so.
- Don't start unrequested work after a PR is merged: report and propose next steps.

## Checks (CI runs the same; run them before pushing)
```bash
dart format --output=none --set-exit-if-changed lib test   # `dart format lib test` to fix
flutter analyze
flutter test
```
CI also builds a release APK (job "Build release APK") and checks the INTERNET permission.

## Code conventions
- State in `ChangeNotifier` controllers (`lib/controllers`), services created once in
  `AppServices` (`lib/app_services.dart`) and read with `context.read`. No singletons.
  Listenable services are provided with `InheritedProvider.value` (Provider rejects Listenables).
- Everything a class needs is injected; tests pass fakes (see `test/support/`). Tests must never
  hit the network.
- User-visible strings go in **both** `lib/l10n/app_en.arb` and `app_it.arb`; the generated
  `app_localizations*.dart` are committed (`flutter gen-l10n` or `flutter pub get` regenerates).
- Sizes with `flutter_screenutil` (`.w .h .r .sp`); colours from `context.colors` (`AppColors`),
  not hard-coded, so dark mode works. Use `ensureContrast` for type colours on surfaces.
- The app is edge-to-edge: bottom sheets and scrollables must add
  `MediaQuery.viewPaddingOf(context).bottom`.
- Pages are split into widgets under `lib/views/<feature>/`; keep files small.
- Match the surrounding code's comment density and naming.

## Sandbox gotchas
- Flutter SDK is at `/opt/fl/flutter/bin` (add it to `PATH`). The "running as root" warning is harmless.
- `flutter pub get`/`analyze`/`test` with the cloud SDK rewrites SDK-pinned entries in
  `pubspec.lock`. Keep the committed lock and change only the lines for packages you added
  (`git checkout pubspec.lock`, then edit by hand or merge only the new packages).
- `pokeapi.co` and `github.com` are unreachable from the sandbox; use fakes.
- `rsync` is not installed; copy with `cp -r`.
- Don't `pkill -f` a pattern that matches your own command line (it kills the shell); start
  background servers with `(nohup … &)` and stop them by PID.
- `tester.pageBack()` taps any "Back" tooltip; use `tester.binding.handlePopRoute()` for system back.
  `IndexedStack` does not pause tickers (the shell wraps tabs in `TickerMode`). The Ahem test font
  makes `Row`s overflow: use `Expanded`. Tests that judge layout against real text widths call
  `loadRoboto()` (`test/support/fonts.dart`) in `setUpAll`.
- Seeing the UI: see "Notes for new sessions" in `docs/planning/backlog.md` (web build + Playwright).

## Release signing
Release APKs are signed with the key from `android/key.properties` or the `ANDROID_*` CI secrets
(see README, "Release signing"). Never commit a keystore, its passwords or `key.properties`.
