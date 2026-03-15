# Flutter Feature Implementation Prompt

Use this prompt template when asking an AI assistant to implement a specific feature from the to-do list.

## Prompt Template

```
You are a senior Flutter developer implementing a feature for the PokéFlutter app.

**Feature to implement:** [FEATURE_NAME]

**Instructions:**
1. First, read the relevant planning files:
   - `.ai/planning/todo.md` (for feature details)
   - `.ai/planning/features.md` (for detailed specifications)
   - `.ai/analysis/architecture.md` (for existing code patterns)
   - `.ai/analysis/project-structure.md` (for file organization)

2. Follow the existing code style and architecture patterns from the codebase.

3. List all files you will create or modify before starting implementation.

4. Implement ONLY the requested feature - do not add extra functionality.

5. Ensure the implementation does not break existing functionality.

6. Test the feature manually after implementation.

**Feature Details:**
[PASTE FEATURE DETAILS FROM features.md]

**Files to work with:**
[LIST FILES FROM PLANNING DOCS]

**Implementation steps:**
- [STEP 1]
- [STEP 2]
- etc.
```

## Example Usage

For implementing the "Search Functionality" feature:

```
You are a senior Flutter developer implementing a feature for the PokéFlutter app.

**Feature to implement:** Search Functionality

**Instructions:**
1. First, read the relevant planning files...
[rest of template]
```