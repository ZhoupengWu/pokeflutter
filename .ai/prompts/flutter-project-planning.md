You are a senior Flutter developer and project manager.

Your goal is to analyze this Flutter repository (a Pokédex app called "pokeflutter") and produce a structured set of planning and tracking files inside the `.ai/` folder.

Important rules:
- Do NOT edit or modify any existing source code files.
- Do NOT modify any existing files inside `.ai/analysis/`.
- Only create new planning/tracking files.
- Base your analysis on the existing source code and the documentation already present in `.ai/analysis/`.

---

## Files to generate

### 1. `.ai/planning/todo.md`

A prioritized to-do list of all missing or incomplete features found in the codebase.

For each item include:
- A short title
- A brief description of what is missing
- Priority: `high` / `medium` / `low`
- Estimated complexity: `small` / `medium` / `large`
- The files that will likely need to be created or modified

Organize items into these sections:
- 🔴 High Priority
- 🟡 Medium Priority
- 🟢 Low Priority

---

### 2. `.ai/planning/features.md`

A feature specification file describing each missing feature in detail.

For each feature include:
- Feature name
- User story ("As a user, I want to...")
- Acceptance criteria (bullet list)
- Affected files (existing or new)
- Notes or edge cases to consider

---

### 3. `.ai/planning/roadmap.md`

A development roadmap organized into phases.

Each phase should include:
- Phase name and goal
- List of features/tasks included
- Dependencies on other phases (if any)

Suggested phases:
- Phase 1: Core functionality (search, detail page, navigation)
- Phase 2: Advanced features (filter, compare, quiz)
- Phase 3: Polish and optimization (caching, error handling, state management refactor)

---

### 4. `.ai/prompts/flutter-feature-implementation.md`

A reusable prompt template that a developer can use to ask an AI assistant to implement any single feature from the to-do list.

The prompt should instruct the AI to:
- Read the relevant `.ai/planning/` files before starting
- Follow the existing code style and architecture
- Implement only the requested feature
- Not break existing functionality
- List the files it will create or modify before starting

---

## Output format

Each file should be well-structured Markdown.
Use clear headings, bullet points, and code references (file paths) where appropriate.
The goal is to give any developer (or AI assistant) a clear map of what needs to be built and how to approach it.

After generating all files, provide a short summary of what was created and where.