# Sundial Calculator — macOS Build Execution Plan

## Target
macOS calculator app for senior executive knowledge workers. Draws on Calculator_Research.md principles (dual-output, visual verification, cognitive load reduction) adapted for professional use.

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
- [x] DisplayView (expression + result + memory indicator)
- [x] KeypadView (button grid with √, ^, %, parens, memory, digits, operators)
- [x] HistoryView (sidebar with recall)
- [x] VisualAnswerView (visual type picker + container)

## Phase 5: Visual Renderers
- [x] NumberLineView (Canvas-based, shows operands + jump arcs)
- [x] BreakdownView (place value decomposition with color-coded blocks)
- [x] ProportionBarView (stacked bars for add/sub, factor display for mul/div)

## Phase 6: Polish
- [x] Dark mode support
- [x] Menu bar with keyboard shortcuts (Calculator + Memory menus)
- [x] Accessibility (VoiceOver labels on all interactive elements, keyboard nav)

## Phase 7: Tests & Test Plan
- [x] Unit tests for computation engine (CalculatorEngineTests.swift — 20 tests)
- [x] User scenario tests (UserScenarioTests.swift — 94 tests across 19 use cases)
- [x] Write comprehensive TEST_PLAN.md
- [x] All 141 tests pass across 26 suites

## Phase 8: Documentation
- [x] CLAUDE.md — project guide
- [x] README.md — user-facing docs
- [x] CHEATSHEET.md — user manual
- [x] TEST_PLAN.md — comprehensive test plan
- [x] MEMORY.md — persistent project memory
- [x] EXECUTION_PLAN.md — this file

## Phase 9: Quality Hardening (Code Audit)
- [x] NaN/Infinity handling — √(negative), (-2)^0.5, overflow from power now throw undefinedResult
- [x] formatResult guards against NaN/Infinity (displays "Error" / "Overflow")
- [x] Error recovery — all input methods (operator, percent, power, √, toggle sign) clear broken expression on error
- [x] Percent operand extraction — visual answers show resolved percent values (e.g., 10% of 200 = 20)
- [x] Integer formatting — large integers display as full numbers (1000000 not 1e+06)
- [x] Quality gap tests (QualityGapTests.swift — 27 tests across 6 suites)
- [x] All 141 tests pass across 26 suites

## Completion
All phases complete. App builds and runs with `swift run`. 141 automated tests pass across 26 suites.

## Architecture Notes
- SwiftUI macOS app via Swift Package Manager
- MVVM: ViewModel drives all state
- Computation engine is pure Swift (no UI dependencies, fully testable)
- Visual renderers are SwiftUI views consuming computed results
- Keyboard-first design for executive users
- 6 operations: +, −, ×, ÷, ^ (power), √ (square root)
