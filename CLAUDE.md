# Sundial Calculator — Project Guide

## Project Overview

Sundial Calculator is a dual-output calculator available on macOS (built) and iOS (planned). The macOS version targets senior executive knowledge workers. It provides symbolic + visual computation with emphasis on meaning verification, cognitive load reduction, and accessibility. Grounded in Montessori-informed design research (see `Calculator_Research.md`).

## Current State

**macOS app (active)**: Built with SwiftUI via Swift Package Manager. Fully functional compute-mode calculator with visual answer panel, history sidebar, keyboard-first interaction, guided input mode, step-by-step replay, accessibility profile, and confidence checks. 167 automated tests across 33 suites, all passing.

**iOS app (planned)**: Future work. See `Calculator_Research.md` for full design spec.

## Architecture (macOS)

- **Platform**: macOS 14+
- **UI Framework**: SwiftUI + SwiftUI Canvas (visual rendering)
- **Build**: Swift Package Manager (`swift build` / `swift run` / `swift test`)
- **Pattern**: MVVM — `CalculatorViewModel` drives all state, `CalculatorEngine` is pure computation
- **Speech**: AVSpeechSynthesizer for spoken meaning checks (accessibility feature)
- **Persistence**: UserDefaults for accessibility profile, visual onboarding state, and bounded calculation history

## Key Design Constraints

- **Montessori principles as engineering constraints**:
  - Concrete-to-abstract: visual verification shows meaning behind numbers
  - Control of error: visual sanity checks catch order-of-magnitude mistakes
  - Freedom within limits: surface only operation-relevant visual answer types
  - Limit field of consciousness: progressive disclosure, clean UI
- **Cognitive load reduction** is a product requirement
- **Accessibility**: VoiceOver labels on all interactive elements, keyboard navigation, Dark Mode, configurable accessibility profile

## Features (macOS)

### Core Calculator
- Expression-based input with full operator precedence (PEMDAS) and parentheses
- Six operations: +, −, ×, ÷, ^ (power, right-associative, precedence 3), √ (prefix unary, precedence 4)
- Percentage — standalone (`50%` = 0.5) and contextual (`200 + 10%` = 220)
- Toggle sign (±), implicit multiply (e.g. `5(` → `5 × (`)
- Memory functions (M+, M−, MR, MC)
- Calculation history sidebar with click-to-recall, restored across launches
- Copy/paste: copy result (Cmd+C), copy expression (Cmd+Shift+E), paste (Cmd+V) with input sanitization
- Error recovery: all input methods clear broken expression after error
- Domain validation: √(negative), negative^fractional, overflow → `undefinedResult` error
- IEEE 754 display: floating-point noise eliminated (e.g., 0.1+0.2 shows "0.3"); integers < 1e15 display without scientific notation

### Input Modes
- **Freeform** — standard calculator input, type naturally
- **Guided** — slot-style flow (`number → operator → number`) with token display and corrective hints; blocks invalid sequences (digit after %, close paren without open)

### Visual Answer Panel
Five visual types, exposed through a context-aware picker:
- **Number Line** — Canvas-based, animated jump arcs for add/subtract, scaled axis with zero anchor
- **Place Value** — Decomposes result into billions...hundredths with animated regroup phases (before → regroup → after)
- **Proportion** — Stacked bars for add/subtract, scaled comparison bars for multiply/divide
- **Magnitude** — Logarithmic scale across orders of magnitude
- **Area** — Grid visualization for ×/÷/^ with auto-scaling for large operands

### Computation Replay
- `evaluateWithTrace` generates step-by-step `ComputationTrace` with `ComputationStep` entries
- Replay controls: previous, next, play/pause (auto-advance timer), reset
- Visual panel syncs to the active replay step
- Replay speed respects accessibility profile (slower animations toggle)

### Confidence & Feedback
- **Confidence check strip** — rough estimate, direction (larger/smaller/equal), sign (positive/negative/zero) for every result
- **Calculation explanation** — natural language summary (e.g., "You started with 48, added 17, and got 65.")
- **Visualization recommendation** — auto-selects best visual type based on operation context
- **Visual onboarding** — first-use helper text per visual type, dismissible, persisted, resettable

### Accessibility Profile (persisted in UserDefaults)
- Slower replay animations
- Large text (scales keypad, display, and guided slots)
- Simplified notation labels (replaces symbols with words: `×` → "times")
- Spoken meaning checks (AVSpeechSynthesizer reads explanation aloud)
- Reduced visual complexity (hides recommendation text, limits line counts)

### Menu Bar
- **Calculator** — Clear, All Clear, Copy Result, Copy Expression, Paste, Toggle Visual Answer
- **Memory** — M+, M−, MR, MC
- **Replay** — Previous Step, Play/Pause, Next Step, Reset Replay
- **Input** — Freeform / Guided mode switching
- **Accessibility** — All 5 profile toggles + Replay Visual Onboarding

### Keyboard Shortcuts
| Key | Action |
|-----|--------|
| 0–9, . | Enter digits |
| +, -, *, / | Operators |
| ^ | Power |
| ( ) | Parentheses |
| % | Percentage |
| Enter or = | Evaluate |
| Escape | Clear |
| Delete | Backspace |
| Cmd+C | Copy result |
| Cmd+Shift+E | Copy expression |
| Cmd+V | Paste |
| Cmd+Shift+V | Toggle visual panel |
| Cmd+Shift+C | Clear |
| Cmd+Shift+A | All Clear |
| Cmd+[ / Cmd+] | Replay previous / next step |
| Cmd+Shift+P | Play/Pause replay |
| Cmd+Shift+R | Reset replay |
| Cmd+Option+1 / 2 | Freeform / Guided mode |

## Code Style

- Swift 5.9+, Apple's Swift API Design Guidelines
- SwiftUI-first
- `@Observable` for state management
- Accessibility modifiers on every interactive element
- Swift Testing framework for unit tests

## File Structure

```
Sources/SundialCalculator/
├── SundialCalculatorApp.swift          # @main App entry point, 5 menu groups
├── Models/
│   ├── CalculatorEngine.swift          # Tokenizer, shunting-yard parser, evaluator, formatting
│   ├── CalculationRecord.swift         # History entry model
│   ├── AccessibilityProfile.swift      # Codable profile with 5 accessibility toggles
│   ├── CalculationFeedback.swift       # VisualizationRecommendation + CalculationExplanation
│   ├── ComputationStep.swift           # Single step in a computation trace (left, right, op, result)
│   ├── ComputationTrace.swift          # Full trace: expression + ordered steps + final result
│   ├── ConfidenceCheck.swift           # Estimate, direction, sign check model
│   └── PlaceValueModel.swift           # Place value decomposition + PlaceValuePhase enum
├── ViewModels/
│   └── CalculatorViewModel.swift       # Main state, input handling, memory, history, replay, accessibility
├── Views/
│   ├── ContentView.swift               # HSplitView layout, keyboard handlers, replay controls
│   ├── DisplayView.swift               # Expression + result + explanation + confidence + guided hints
│   ├── KeypadView.swift                # Button grid, input mode picker, guided slot display
│   └── HistoryView.swift               # Sidebar with history entries
└── VisualAnswers/
    ├── VisualAnswerView.swift           # Visual type picker + recommendation + onboarding + container
    ├── NumberLineView.swift             # Canvas-based number line with animated jumps
    ├── NumberLineMath.swift             # Pure-logic axis/tick computation (extracted for testability)
    ├── BreakdownView.swift              # Place value decomposition with animated phases
    ├── ProportionBarView.swift          # Proportion/percentage bars + multiplicative comparison
    ├── OrderOfMagnitudeView.swift       # Logarithmic magnitude scale
    └── AreaGridView.swift               # Grid visualization for ×/÷/^

Tests/SundialCalculatorTests/
├── HistoryPersistenceTests.swift        # 3 persisted-history tests
├── CalculatorEngineTests.swift          # 20 engine unit tests
├── UserScenarioTests.swift              # 96 user scenario tests (19 use cases, UC1–UC19)
├── QualityGapTests.swift                # 27 quality gap tests (6 suites, QG1–QG6)
├── AccessibilityProfileTests.swift      # 3 accessibility profile tests
├── ComputationTraceTests.swift          # 4 computation trace tests
├── ConfidenceCheckTests.swift           # 3 confidence check tests
├── GuidedInputTests.swift               # 4 guided input tests
├── NumberLineMathTests.swift            # 4 number line math tests
└── PlaceValueModelTests.swift           # 3 place value model tests
```

## Development Workflow

- `swift build` — compile
- `swift test` — run all 167 automated tests across 33 suites
- `swift run` — launch the app
- `./build-app.sh` — bundle as macOS .app with Info.plist
- Run tests before committing
- Test with VoiceOver and in Dark Mode for any UI change
- Visual renderers must match computed result (truth constraint)

## Key Files

- `README.md` — Project overview, quick start, feature summary
- `Calculator_Research.md` — Full design research document
- `EXECUTION_PLAN.md` — Build execution plan with progress tracking
- `TEST_PLAN.md` — Comprehensive test plan
- `CHEATSHEET.md` — User manual for first-time users
- `Package.swift` — SPM project definition
- `build-app.sh` — Script to bundle as macOS .app with Info.plist
