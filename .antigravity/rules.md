# Golfer Autonomous Daily Sprint Rule

When the user prompts **"run daily sprint"** (or similar phrasing):

1. **Locate Next Task**:
   - Inspect `docs/AUTONOMOUS_BACKLOG.md`.
   - Find the first unchecked sprint item formatted as `- [ ] **Sprint X: ...**`.

2. **Autonomous Implementation**:
   - Implement the complete user-facing capability, controllers, domain models, and UI widgets following Clean Architecture & MVVM standards.
   - Strictly adhere to:
     - Zero hardcoded colors (resolve dynamically via `Theme.of(context).colorScheme`).
     - Unique hero tags on any `FloatingActionButton`.
     - Zero emojis in source code, logs, or UI strings.
     - Zero `// TODO` or tutorial comments.
     - Landscape safe 800x360 layout.
     - Wrap forms with inline validation.

3. **Automated Verification**:
   - Write corresponding automated unit and/or widget tests in `test/unit/` or `test/widget/`.
   - Run `flutter analyze` and ensure 0 issues found.
   - Run `flutter test` and ensure 100% test pass rate.

4. **Mark Done & Push**:
   - Mark the completed sprint item in `docs/AUTONOMOUS_BACKLOG.md` as `- [x] **Sprint X: ...**`.
   - Commit the changes with conventional commit format: `feat(sprint-X): <sprint title>`.
   - Push commit to `origin main`.
   - Report concise completion summary to the user.
