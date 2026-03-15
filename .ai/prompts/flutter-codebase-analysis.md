You are a senior Flutter architect and codebase analyst.

Your goal is to analyze this entire Flutter repository and produce a clear architectural overview of the project.

Important rules:

- Do NOT edit or modify any files.
- Only analyze and explain the codebase.
- Explore the full repository before answering.

Focus especially on the structure inside the "lib/" folder and the project's architecture.

---

1. Project Overview

Explain:

- what the application appears to do
- the main purpose of the project
- the main technologies used
- the Flutter architecture style (feature-based, layered, MVVM, clean architecture, etc.)

---

2. Repository Structure

Describe the repository layout.

Explain the purpose of important folders such as:

- lib/
- android/
- ios/
- web/
- macos/
- assets/
- test/

Focus especially on the structure inside "lib/".

Explain how the project is organized.

---

3. Flutter Architecture

Analyze how the Flutter code is structured.

Explain:

- feature organization
- widget hierarchy
- separation between UI and business logic
- service layers
- data layers

Determine if the project follows patterns such as:

- Clean Architecture
- MVVM
- Feature-based architecture
- Layered architecture

---

4. State Management

Identify the state management approach used.

Examples include:

- Provider
- Riverpod
- Bloc / Cubit
- GetX
- setState
- custom solutions

Explain how state flows through the app.

---

5. Navigation and Routing

Analyze how navigation works.

Explain:

- routing strategy
- where routes are defined
- navigation patterns
- deep linking if present

---

6. Core Widgets and Screens

Identify the most important screens and widgets.

Explain:

- their responsibilities
- how they interact
- how UI composition is handled

Focus on the most important UI entry points.

---

7. Services and Data Layer

Identify:

- API services
- repositories
- models
- local storage
- networking logic

Explain how data flows from backend → services → UI.

---

8. Dependencies

Analyze the "pubspec.yaml" file.

List:

- important packages
- why they are used
- potential heavy or risky dependencies.

---

9. Code Quality Observations

Provide observations about:

- code organization
- modularity
- file sizes
- widget complexity
- separation of concerns

Highlight good practices and potential issues.

Do NOT suggest code edits yet.

---

10. Potential Technical Debt

Identify possible issues such as:

- large widgets
- mixed UI/business logic
- duplicated code
- tight coupling
- unclear module boundaries

---

11. Refactoring Opportunities

Suggest architectural improvements such as:

- better folder organization
- splitting large widgets
- introducing better state management patterns
- modularizing features

Do NOT implement them.

---

12. Developer Onboarding Guide

Explain how a new developer should explore this codebase.

Include:

- which files to read first
- which modules are most important
- which parts can be ignored initially.

---

Output format

Produce a structured Markdown report with clear sections.

The goal is to help a developer quickly understand the architecture of the project.

After completing the analysis, generate documentation files inside the following folder:

.ai/analysis/

Create these Markdown files:

1. project-overview.md
2. architecture.md
3. project-structure.md
4. dependencies.md
5. technical-debt.md
6. onboarding-guide.md

Each file should contain the corresponding section from your analysis.

If the ".ai/analysis/" folder does not exist, create it.

Do not modify any existing source code files.
Only create documentation files.