# Flutter Feature Implementation Prompt

Use this prompt template when asking an AI assistant to implement a specific feature from the backlog.

## Prompt Template

```
You are a senior Flutter developer implementing a feature for the PokéFlutter app.

**Feature to implement:** [FEATURE_NAME]

**Instructions:**
1. First, read the relevant planning files:
   - `docs/planning/backlog.md` (what is planned and why)
   - `docs/analysis/architecture.md` (layout, data flow, testing conventions)
   - `docs/analysis/technical-debt.md` (known weak spots to avoid making worse)

2. Follow the existing code style and architecture patterns from the codebase.

3. List all files you will create or modify before starting implementation.

4. Implement ONLY the requested feature - do not add extra functionality.

5. Add tests (inject fakes for HTTP / storage, never hit the network) and make sure these pass,
   they are what CI runs:
   `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`.

6. Commit in small, focused commits and update `docs/planning/` (move the item from the backlog
   to `roadmap.md` / `todo.md`) and `docs/analysis/architecture.md` if the structure changed.

**Feature Details:**
[PASTE THE BACKLOG ENTRY]

**Files to work with:**
[LIST FILES, SEE architecture.md]

**Implementation steps:**
- [STEP 1]
- [STEP 2]
- etc.
```

## Example Usage

For implementing the "Evolution chain" feature:

```
You are a senior Flutter developer implementing a feature for the PokéFlutter app.

**Feature to implement:** Evolution chain on the detail page

**Instructions:**
1. First, read the relevant planning files...
[rest of template]
```