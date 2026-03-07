# Sundial Calculator — Project Guide

## Project Overview

Sundial Calculator is a dual-output calculator available on macOS (built) and iOS (planned). The macOS version targets senior executive knowledge workers. It provides symbolic + visual computation with emphasis on meaning verification, cognitive load reduction, and accessibility. Grounded in Montessori-informed design research (see `Calculator_Research.md`).

## Current State

**macOS app (active)**: Built with SwiftUI via Swift Package Manager. Fully functional compute-mode calculator with visual answer panel, history sidebar, keyboard-first interaction. 141 automated tests across 26 suites, all passing.

**iOS app (planned)**: Future work. See `Calculator_Research.md` for full design spec.

## Architecture (macOS)

- **Platform**: macOS 14+
- **UI Framework**: SwiftUI + SwiftUI Canvas (visual rendering)
- **Build**: Swift Package Manager (`swift build` / `swift run` / `swift test`)
- **Pattern**: MVVM — `CalculatorViewModel` drives all state, `CalculatorEngine` is pure computation

## Key Design Constraints

- **Montessori principles as engineering constraints**:
  - Concrete-to-abstract: visual verification shows meaning behind numbers
  - Control of error: visual sanity checks catch order-of-magnitude mistakes
  - Freedom within limits: choose from 6 visual answer types
  - Limit field of consciousness: progressive disclosure, clean UI
- **Cognitive load reduction** is a product requirement
- **Accessibility**: VoiceOver labels on all interactive elements, keyboard navigation, Dark Mode

## Features (macOS)

- Expression-based input with full operator precedence (PEMDAS) and parentheses
- Six operations: +, −, ×, ÷, ^ (power), √ (square root)
- Percentage — standalone (`50%` = 0.5) and contextual (`200 + 10%` = 220)
- Toggle sign (±)
- Memory functions (M+, M−, MR, MC)
- Visual answer panel: Number Line, Place Value Breakdown, Proportion Bar, Order of Magnitude, Factor Ratio, Area Grid
- Calculation history sidebar with click-to-recall
- Full keyboard support (digits, operators, ^, Enter, Escape, Delete)
- Menu bar with Cmd shortcuts
- Dark Mode and Light Mode
- Error recovery: all input methods (digits, operators, %, ^, √, ±) clear broken expression after error
- Domain validation: √(negative), negative^fractional, overflow → `undefinedResult` error
- IEEE 754 display: floating-point noise eliminated (e.g., 0.1+0.2 shows "0.3"); integers display without scientific notation

## Code Style

- Swift 5.9+, Apple's Swift API Design Guidelines
- SwiftUI-first
- `@Observable` for state management
- Accessibility modifiers on every interactive element
- Swift Testing framework for unit tests

## File Structure

```
Sources/SundialCalculator/
├── SundialCalculatorApp.swift          # @main App entry point, menu commands
├── Models/
│   ├── CalculatorEngine.swift          # Tokenizer, shunting-yard parser, evaluator
│   └── CalculationRecord.swift         # History entry model
├── ViewModels/
│   └── CalculatorViewModel.swift       # Main state, input handling, memory, history
├── Views/
│   ├── ContentView.swift               # HSplitView layout, keyboard handlers
│   ├── DisplayView.swift               # Expression + result display
│   ├── KeypadView.swift                # Button grid with CalcButtonStyle
│   └── HistoryView.swift               # Sidebar with history entries
└── VisualAnswers/
    ├── VisualAnswerView.swift           # Visual type picker + container
    ├── NumberLineView.swift             # Canvas-based number line
    ├── BreakdownView.swift              # Place value decomposition
    ├── ProportionBarView.swift          # Proportion/percentage bars
    ├── OrderOfMagnitudeView.swift       # Logarithmic magnitude scale
    ├── FactorRatioView.swift            # Factor/ratio comparison bars
    └── AreaGridView.swift               # Grid visualization for ×/÷/^

Tests/SundialCalculatorTests/
├── CalculatorEngineTests.swift          # 20 engine unit tests
├── UserScenarioTests.swift             # 94 user scenario tests (19 use cases)
└── QualityGapTests.swift               # 27 quality gap tests (6 suites)
```

## Development Workflow

- `swift build` — compile
- `swift test` — run all 141 automated tests
- `swift run` — launch the app
- Run tests before committing
- Test with VoiceOver and in Dark Mode for any UI change
- Visual renderers must match computed result (truth constraint)

## Key Files

- `Calculator_Research.md` — Full design research document
- `EXECUTION_PLAN.md` — Build execution plan with progress tracking
- `TEST_PLAN.md` — Comprehensive test plan
- `CHEATSHEET.md` — User manual for first-time users
- `Package.swift` — SPM project definition
