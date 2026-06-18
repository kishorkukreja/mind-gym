# Issue 016 Typography Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the core Mind Gym training loop feel calm, serious, and readable across auth/onboarding, home, debate, completion, and progress screens.

**Architecture:** Keep the existing Flutter screen structure and introduce a small shared typography layer in `AppTheme`. Screen changes consume shared text styles and spacing constants rather than creating one-off typography.

**Tech Stack:** Flutter, Material 3, `google_fonts`, Provider, existing local-first storage and challenge models.

---

## Issue Context

Issue #16 is open and requests visual and typography polish across the training loop. It is marked blocked by #3 and #4, which are also open. This pass treats those blockers as scope boundaries: it polishes the existing first-run/auth, home, debate, completion, and progress surfaces without introducing the starter challenge flow from #3 or the expanded challenge state model from #4.

Relevant PRD user stories:

- User story 45: UI typography should feel calm and serious so long challenge text is pleasant to read.
- User story 46: polish should support comfortable reading at night in a future dark mode.
- User story 47: screens should feel less like generic Flutter defaults and more like a deliberate product.

## Visual Direction

**Visual thesis:** Mind Gym should feel like a focused reading room for hard thinking: quiet surfaces, disciplined spacing, sharp labels, and warmer long-form challenge text.

**Font pairing:**

- UI font: Inter via `GoogleFonts.inter`, used for navigation, buttons, labels, stats, and compact product UI.
- Reading font: Lora via `GoogleFonts.lora`, used for long challenge prompts and AI/debate prose where line length and rhythm matter.

**Content plan:**

- Auth/onboarding: brand, short premise, focused credential form, clear primary action.
- Home: level/progress, next challenge timing, weekly challenge list, compact stats.
- Debate: challenge prompt as a readable long-form block, clear collapse affordance, readable message bubbles, persistent hint/send controls.
- Completion: completion state, XP earned, return action.
- Progress: brain development, XP progress, weekly report, all-time stats.

**Interaction thesis:**

- Preserve existing entrance and challenge collapse animations.
- Use small state transitions for active tabs, completion, and debate input affordances.
- Avoid adding decorative motion; hierarchy comes from type, spacing, and state color.

## File Structure

- Modify `lib/utils/theme.dart`: define typography constants, shared radius, reading text styles, label styles, metric styles, and button text styles.
- Modify `lib/screens/auth_screen.dart`: align brand and form copy with shared styles; add concise onboarding premise; improve mobile spacing.
- Modify `lib/screens/home_screen.dart`: apply shared label, card title, preview, and stat styles; replace broken emoji text; improve challenge preview readability.
- Modify `lib/screens/debate_screen.dart`: apply Lora reading styles to challenge text and messages; replace mojibake; improve completion dialog copy hierarchy.
- Modify `lib/screens/progress_screen.dart`: apply shared metric and label styles; replace mojibake; prevent dense weekly stats from feeling cramped.
- Modify `lib/screens/main_shell.dart`: apply shared navigation typography and radius.
- Modify `lib/main.dart`: apply shared brand typography on splash.
- Modify `lib/services/app_provider.dart` and `lib/services/openrouter_service.dart`: clean user-visible warning and hint copy in debate fallback paths.
- Add `test/theme_typography_test.dart`: verify theme exposes the expected Inter/Lora typography roles.
- Add `test/training_loop_copy_test.dart`: verify key user-visible text no longer exposes common mojibake sequences.

## Tasks

### Task 1: Typography Contract Tests

**Files:**
- Create: `test/theme_typography_test.dart`
- Create: `test/training_loop_copy_test.dart`

- [x] **Step 1: Write failing tests**

Added tests expecting `AppTheme.readingTextStyle`, `AppTheme.challengePromptTextStyle`, `AppTheme.sectionLabelStyle`, and cleaned training-loop source strings.

- [x] **Step 2: Run tests to verify failure**

Run: `flutter test test/theme_typography_test.dart test/training_loop_copy_test.dart`

Result: Blocked locally because `flutter` is not installed on PATH. The tests were still added before production code changes and are expected to fail before the new theme helpers exist.

### Task 2: Shared Typography Layer

**Files:**
- Modify: `lib/utils/theme.dart`

- [x] **Step 1: Implement typography helpers**

Added Inter/Lora helper styles for brand, section labels, CTA text, metrics, reading copy, challenge prompts, and debate messages.

- [x] **Step 2: Run focused tests**

Run: `flutter test test/theme_typography_test.dart`

Result: Blocked locally because `flutter` is not installed on PATH.

### Task 3: Screen Polish

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/screens/auth_screen.dart`
- Modify: `lib/screens/main_shell.dart`
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/screens/debate_screen.dart`
- Modify: `lib/screens/progress_screen.dart`
- Modify: `lib/models/challenge_model.dart`
- Modify: `lib/services/app_provider.dart`
- Modify: `lib/services/openrouter_service.dart`

- [x] **Step 1: Apply shared styles**

Shared styles now cover brand text, section labels, nav labels, challenge previews, debate prompt text, message text, metrics, and CTA text.

- [x] **Step 2: Preserve behavior**

No provider state transitions, scheduling, completion gating, persistence, navigation destinations, or API call flow were changed.

- [x] **Step 3: Clean visible mojibake in touched training-loop screens**

Broken sequences were removed from core screen and debate fallback strings. Type labels now use text-only labels while screen components provide visual distinction through color and icons.

### Task 4: Verification

**Files:**
- Modify: `docs/specs/issue-016-typography-polish.md`

- [x] **Step 1: Run formatter and tests**

Commands:

```bash
dart format --set-exit-if-changed lib test
flutter test
flutter analyze
```

Result: all three are blocked locally because `dart` and `flutter` are not installed on PATH. `where.exe dart` and `where.exe flutter` also returned no installed executable.

- [x] **Step 2: Manual layout checks**

Source-level manual checks completed:

- Auth: brand, premise, form card, and primary action use shared styles with stable radius and button height.
- Home: weekly challenge label, state badges, challenge previews, countdown, and quick stats use consistent hierarchy and fixed-size controls.
- Debate: prompt block uses `AppTheme.challengePromptTextStyle` on a warm reading surface; messages use `AppTheme.messageTextStyle`; completion dialog has clear icon, XP, and return action.
- Progress: top label, weekly report label, all-time label, metric values, grade badge, and stat cells use shared hierarchy.
- Mobile state clarity: key action labels remain visible (`Tap to debate`, `Opens ...`, `Complete`, `Hint`, send icon, `Back to Training`) and no source-level fixed widths were added that would force obvious mobile overflow.

Additional static checks:

```bash
git diff --check
rg "<common mojibake marker set>" lib docs -n
```

Result: `git diff --check` exited 0. The mojibake scan returned no matches.

## Out of Scope

- Starter challenge first-run flow from #3.
- Full weekly challenge state model from #4.
- Dark mode implementation.
- New backend, auth provider, analytics, or scoring behavior.
- Golden screenshot infrastructure.

## Verification Record

Automated Flutter verification and screenshots could not be produced in this local environment because Flutter/Dart tooling is absent. The PR includes tests and static verification notes so the normal Flutter CI or a machine with Flutter installed can run the full checks.
