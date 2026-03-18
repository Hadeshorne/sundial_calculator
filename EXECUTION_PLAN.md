# Sundial Calculator — macOS Build Execution Plan

## Target
macOS calculator app for senior executive knowledge workers. Draws on `Calculator_Research.md` principles (dual-output, visual verification, cognitive load reduction) adapted for professional use.

## Status Key
- [ ] Not started
- [x] Complete

## Phase 1: Project Setup
- [x] Create Package.swift for macOS SwiftUI app
- [x] Create source directory structure
- [x] Verify builds

## Phase 2: Computation Engine
- [x] Expression tokenizer (Token types, lexer)
- [x] Shunting-yard parser (infix to postfix)
- [x] Evaluator with error handling
- [x] Percentage support (standalone + contextual)
- [x] Memory functions (M+, M−, MR, MC)
- [x] Power operator (^) with right-associativity
- [x] Square root (√) as prefix unary operator

## Phase 3: Models & State
- [x] CalculationRecord model (history entries)
- [x] CalculatorViewModel (main state management)
- [x] History management
- [x] Keyboard input handling
- [x] Error recovery (expression clears on new input after error)

## Phase 4: Views
- [x] ContentView (HSplitView layout with keyboard handlers)
- [x] DisplayView (expression + result + feedback)
- [x] KeypadView (button grid with √, ^, %, parens, memory, digits, operators)
- [x] HistoryView (sidebar with recall)
- [x] VisualAnswerView (visual type picker + container)

## Phase 5: Visual Renderers
- [x] NumberLineView (Canvas-based, zero anchor, directional jump cues)
- [x] BreakdownView (decimal-aware place value with regroup phases)
- [x] ProportionBarView (including multiplicative comparison bars)
- [x] OrderOfMagnitudeView
- [x] AreaGridView

## Phase 6: Product Polish
- [x] Dark mode support
- [x] Menu bar with keyboard shortcuts (Calculator, Memory, Replay, Input, Accessibility)
- [x] Accessibility labels on interactive elements
- [x] Keyboard navigation and keyboard-first workflow

## Phase 7: Tests & Test Plan
- [x] Unit tests for computation engine (`CalculatorEngineTests.swift` — 20 tests)
- [x] User scenario tests (`UserScenarioTests.swift` — 96 tests across 19 use cases)
- [x] Quality gap tests (`QualityGapTests.swift` — 27 tests across 6 suites)
- [x] Milestone suites added:
  - `HistoryPersistenceTests.swift` (3)
  - `ComputationTraceTests.swift` (4)
  - `NumberLineMathTests.swift` (4)
  - `PlaceValueModelTests.swift` (3)
  - `GuidedInputTests.swift` (4)
  - `ConfidenceCheckTests.swift` (3)
  - `AccessibilityProfileTests.swift` (3)
- [x] `TEST_PLAN.md` updated for milestones 2-8 coverage
- [x] All 167 tests pass across 33 suites

## Phase 8: Documentation
- [x] `README.md` updated with replay/guided/profile/confidence/onboarding behavior
- [x] `CHEATSHEET.md` updated with new workflows and shortcuts
- [x] `TEST_PLAN.md` updated with automated/manual milestone coverage
- [x] `EXECUTION_PLAN.md` refreshed (this file)

## Phase 9: Quality Hardening
- [x] NaN/Infinity handling for undefined math domains
- [x] Percent operand extraction for visual-answer truth alignment
- [x] Replay and visualization synchronization
- [x] Guided mode corrective hints for common syntax errors
- [x] Confidence checks for both binary and complex expressions
- [x] Profile persistence + visual onboarding lifecycle persistence
- [x] Speech implementation moved to `AVSpeechSynthesizer` (macOS 14-compatible)

## Phase 10: Dyscalculia Milestones 2-8
- [x] Milestone 2 — Step replay (order-of-operations playback)
- [x] Milestone 3 — Number line 2.0 (zero anchor + stable axis math)
- [x] Milestone 4 — Place value 2.0 (decimals + regroup phases)
- [x] Milestone 5 — Guided input mode (slot strip + syntax guards)
- [x] Milestone 6 — Personalization profile (runtime toggles + persistence)
- [x] Milestone 7 — Confidence layer + visual onboarding lifecycle
- [x] Milestone 8 — Quality/accessibility/docs hardening

## Completion
All planned milestones are complete. App builds and runs with `swift run`. Automated suite passes at **167 tests across 33 suites** (`swift test`, run on **March 10, 2026**).

## Architecture Notes
- SwiftUI macOS app via Swift Package Manager
- MVVM: ViewModel drives all state
- Computation engine is pure Swift (no UI dependencies, fully testable)
- Visual renderers consume computed or replay-step context
- Keyboard-first design with optional guided mode
- Operations: +, −, ×, ÷, ^ (power), √ (square root), standalone/contextual %
