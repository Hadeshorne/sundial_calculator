# Codex Implementation Plan: Milestones 2-8

This plan assumes Milestone 1 (auto-visual recommendation + plain-language explanation) is complete.

Execution status (March 8, 2026): Milestones 2-8 are implemented. Current baseline is **164 passing tests across 32 suites**.

## Milestone 2 - Step Replay (Order-of-Operations Playback)

### Goal
Enable users to step through how the calculator solved an expression, reducing working-memory load for dyscalculia.

### Scope
- Add computation trace generation in the engine.
- Add UI controls for replay (`Back`, `Play/Pause`, `Next`, `Reset`).
- Synchronize visual panel with current replay step.

### Code Changes
- `Sources/SundialCalculator/Models/`
  - Add `ComputationStep.swift` (step model).
  - Add `ComputationTrace.swift` (sequence + metadata).
- `Sources/SundialCalculator/Models/CalculatorEngine.swift`
  - Add `evaluateWithTrace(_:)`.
  - Keep `evaluate(_:)` as compatibility entry point.
- `Sources/SundialCalculator/ViewModels/CalculatorViewModel.swift`
  - Add playback state: `trace`, `currentStepIndex`, `isPlaying`.
  - Add actions: `replayNext`, `replayPrevious`, `replayReset`, `toggleReplay`.
- `Sources/SundialCalculator/Views/ContentView.swift`
  - Add replay toolbar/row below display.
- `Sources/SundialCalculator/Views/DisplayView.swift`
  - Add short step caption during replay.

### Tests
- Add `Tests/SundialCalculatorTests/ComputationTraceTests.swift`.
- Extend `UserScenarioTests.swift` with replay flows.
- Ensure full suite passes (current baseline: 164 tests).

### Exit Criteria
- Users can step through `(2 + 3) × 4` and see two explicit operations.
- Replay state survives visual-type switching.
- Keyboard controls work without mouse.

## Milestone 3 - Number Line 2.0 (Dyscalculia-first)

### Goal
Make add/subtract visually unambiguous with stable anchors and direction cues.

### Scope
- Always render zero anchor.
- Use consistent tick strategy (no confusing decimal jitter).
- Directional animated jumps for add/subtract.
- Better labels for negative values.

### Code Changes
- `Sources/SundialCalculator/VisualAnswers/NumberLineView.swift`
  - Extract range/tick math into pure helper logic.
  - Add animation hooks for replay step.
- Optional helper file:
  - `Sources/SundialCalculator/VisualAnswers/NumberLineMath.swift`

### Tests
- Add `Tests/SundialCalculatorTests/NumberLineMathTests.swift`.
- Add scenario tests for negative and mixed-sign operations.

### Exit Criteria
- Zero is visible in all add/sub views.
- Left/right movement is visually consistent with operation sign.

## Milestone 4 - Place Value 2.0 (Decimals + Regrouping)

### Goal
Improve place-value comprehension, especially borrow/carry and decimal place transitions.

### Scope
- Show tenths/hundredths in visual decomposition.
- Animate regrouping for carry/borrow.
- Improve negative-number decomposition clarity.

### Code Changes
- `Sources/SundialCalculator/VisualAnswers/BreakdownView.swift`
  - Replace integer-only decomposition with decimal-aware decomposition.
  - Add regroup states (`before`, `regroup`, `after`).
- Add model helper:
  - `Sources/SundialCalculator/Models/PlaceValueModel.swift`

### Tests
- Add `Tests/SundialCalculatorTests/PlaceValueModelTests.swift`.
- Extend `UserScenarioTests.swift` for decimal and borrow/carry examples.

### Exit Criteria
- `12.3 + 0.8` and `1002 - 19` produce clear, interpretable place-value visuals.

## Milestone 5 - Guided Input Mode (Syntax Reduction)

### Goal
Reduce expression syntax errors and anxiety by introducing a structured input path.

### Scope
- Add optional guided composer with token slots.
- Keep free-form input available.
- Replace terse errors with corrective guidance.

### Code Changes
- `Sources/SundialCalculator/ViewModels/CalculatorViewModel.swift`
  - Add `inputMode` (`freeform`, `guided`).
  - Add token-slot editing actions.
- `Sources/SundialCalculator/Views/KeypadView.swift`
  - Add guided-mode controls.
- `Sources/SundialCalculator/Views/DisplayView.swift`
  - Add corrective hint text for invalid expressions.

### Tests
- Extend `QualityGapTests.swift` for guided-mode error recovery.
- Extend `UserScenarioTests.swift` for guided-mode completion flow.

### Exit Criteria
- Common syntax errors are preventable in guided mode.
- Error text always suggests a next action.

## Milestone 6 - Personalization Profile (Dyscalculia Settings)

### Goal
Support different cognitive needs with profile-based UI behavior.

### Scope
- Add profile settings:
  - slower animation
  - larger spacing/text
  - reduced notation density
  - optional spoken meaning checks
- Persist profile across launches.

### Code Changes
- Add `Sources/SundialCalculator/Models/AccessibilityProfile.swift`.
- `Sources/SundialCalculator/ViewModels/CalculatorViewModel.swift`
  - Store/apply profile settings.
- `Sources/SundialCalculator/Views/ContentView.swift`
  - Add settings entry point.
- `Sources/SundialCalculator/SundialCalculatorApp.swift`
  - Add menu command for profile settings.

### Tests
- Add `Tests/SundialCalculatorTests/AccessibilityProfileTests.swift`.
- Add UI-state tests for profile toggles.

### Exit Criteria
- Profile toggles update runtime behavior without restart.
- Settings persist reliably.

## Milestone 7 - Confidence Check Layer + Onboarding

### Goal
Help users self-verify results and learn visual meanings over time.

### Scope
- Add confidence-check strip:
  - estimate band (rough expected range)
  - direction check (larger/smaller)
  - sign check (positive/negative)
- Add first-run micro-onboarding for each visual type.

### Code Changes
- Add `Sources/SundialCalculator/Models/ConfidenceCheck.swift`.
- `Sources/SundialCalculator/ViewModels/CalculatorViewModel.swift`
  - compute confidence-check metadata per result.
- `Sources/SundialCalculator/Views/DisplayView.swift`
  - render confidence strip.
- `Sources/SundialCalculator/VisualAnswers/VisualAnswerView.swift`
  - add onboarding prompts/tooltips.

### Tests
- Add `Tests/SundialCalculatorTests/ConfidenceCheckTests.swift`.
- Extend user scenarios to validate prompts are dismissible and persistent state is tracked.

### Exit Criteria
- Every result displays confidence cues.
- Onboarding appears once per visual type and can be replayed from settings.

## Milestone 8 - Quality, Accessibility, and Release Hardening

### Goal
Ship a stable dyscalculia-centered release with strong quality gates.

### Scope
- Performance profiling for trace + animations.
- VoiceOver audit for replay controls and explanation text.
- Regression coverage for all visual recommendations.
- Final docs update and release checklist.

### Code Changes
- `TEST_PLAN.md`
  - Add milestone 2-7 manual/automated cases.
- `EXECUTION_PLAN.md`
  - Update progress and final run records.
- `README.md` and `CHEATSHEET.md`
  - Document new replay and guided-input behavior.

### Tests
- Expand automated suite for all new models and flows.
- Run full test matrix plus manual accessibility pass.

### Exit Criteria
- Automated tests pass.
- Manual accessibility checklist passes.
- Documentation matches shipped behavior.

---

## Recommended Execution Order
1. Milestone 2
2. Milestone 3
3. Milestone 4
4. Milestone 5
5. Milestone 6
6. Milestone 7
7. Milestone 8

## Risk Controls
- Keep each milestone behind a small feature flag where practical.
- Avoid breaking `evaluate(_:)` API while adding trace functionality.
- Run `swift test` after each milestone and before every commit.
