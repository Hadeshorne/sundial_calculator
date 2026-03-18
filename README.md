# Sundial Calculator

A dual-output calculator for macOS that pairs every numeric result with a visual sanity check. Built for senior executive knowledge workers who need fast, accurate calculation with instant visual verification.

## Quick Start

```bash
# Build
swift build

# Run
swift run

# Test
swift test
```

Requires: macOS 14+ and Xcode Command Line Tools (Swift 5.9+).

## Features

### Compute Mode
- **Expression input** — type full expressions like `(100 + 50) × 2 ÷ 3`
- **Guided input mode** — optional slot-style flow (`number → operator → number`) with corrective hints
- **Operator precedence** — correct PEMDAS/BODMAS order of operations
- **Parentheses** — group sub-expressions
- **Power** — `5^2` = 25, `1.05^10` ≈ 1.629 (compound interest)
- **Square root** — `√144` = 12, `√25 + 3` = 8
- **Percentage** — standalone (`50%` = 0.5) and contextual (`200 + 10%` = 220)
- **Memory** — M+, M−, MR, MC for running totals

### Visual Answer Panel
Every result includes an optional visual check — the picker narrows to the most relevant three choices for the current calculation:
- **Number Line** — shows operands and result on a scaled line with jump arcs
- **Place Value** — decomposes results into billions...hundredths with regroup animation states
- **Proportion** — bar visualization showing composition and multiplicative comparison
- **Magnitude** — logarithmic scale showing where numbers fall across orders of magnitude
- **Area** — grid visualization for multiplication, division, and power operations
- **Replay step mode** — move backward/forward through order-of-operations and sync visuals per step
- **Visual onboarding** — first-use helper text per visual type with dismiss/reset support

### Confidence and Personalization
- **Confidence check strip** — estimate, direction, and sign cues for every result (with complex-expression fallback)
- **Accessibility profile** — slower replay animation, large text, simplified notation labels, spoken meaning checks, reduced visual complexity
- **Persistent settings** — profile and onboarding state are saved across launches

### History Sidebar
- Recent calculations saved across launches
- Click any entry to recall it
- Newest first

### Keyboard-First Design
| Key | Action |
|-----|--------|
| 0–9, . | Enter digits |
| +, -, *, / | Operators |
| ^ | Power (exponent) |
| ( ) | Parentheses |
| % | Percentage |
| Enter or = | Evaluate |
| Escape | Clear |
| Delete | Backspace |
| Cmd+C | Copy result |
| Cmd+Shift+E | Copy expression |
| Cmd+V | Paste into expression |
| Cmd+Shift+V | Toggle visual panel |
| Cmd+Shift+C | Clear expression |
| Cmd+Shift+A | All Clear (history + memory) |
| Cmd+[ / Cmd+] | Replay previous/next step |
| Cmd+Shift+P | Play/Pause replay |
| Cmd+Shift+R | Reset replay |
| Cmd+Option+1 / Cmd+Option+2 | Switch Freeform/Guided input mode |

### Accessibility
- VoiceOver labels on all interactive elements
- Full keyboard navigation
- Dark Mode and Light Mode support
- High-contrast button styling
- VoiceOver labels for replay controls, guided composer, confidence strip, and onboarding prompts

## Design Principles

Grounded in [Montessori-informed design research](Calculator_Research.md):

- **Visual verification** — every result can be visually checked for magnitude and structure
- **Cognitive load reduction** — clean UI, progressive disclosure, no clutter
- **Control of error** — visual answers help catch order-of-magnitude mistakes
- **Freedom within limits** — the picker narrows to operation-appropriate visual types

## Architecture

- SwiftUI macOS app built with Swift Package Manager
- MVVM pattern: `CalculatorViewModel` → `CalculatorEngine`
- Pure Swift computation engine (no UI dependencies, fully unit-tested)
- Visual renderers are interchangeable SwiftUI views
- 167 automated tests across 33 suites

## Project Structure

```
Sources/SundialCalculator/
├── SundialCalculatorApp.swift      # App entry point, 5 menu groups
├── Models/                         # Engine, data models, accessibility, traces
│   ├── CalculatorEngine.swift      # Tokenizer, shunting-yard parser, evaluator
│   ├── CalculationRecord.swift     # History entry model
│   ├── AccessibilityProfile.swift  # Persisted accessibility toggles
│   ├── CalculationFeedback.swift   # Recommendation + explanation models
│   ├── ComputationStep.swift       # Single replay step
│   ├── ComputationTrace.swift      # Full computation trace
│   ├── ConfidenceCheck.swift       # Estimate/direction/sign check
│   └── PlaceValueModel.swift       # Place value decomposition
├── ViewModels/                     # State management
├── Views/                          # UI components
└── VisualAnswers/                  # Visual renderers + NumberLineMath
Tests/SundialCalculatorTests/       # 167 tests across 33 suites
```

## Testing

See [TEST_PLAN.md](TEST_PLAN.md) for the comprehensive test plan.

```bash
swift test   # Runs 167 automated tests across 33 suites
swift run    # Launch app for manual testing
```

## Documentation

- [CHEATSHEET.md](CHEATSHEET.md) — User manual for first-time users
- [CLAUDE.md](CLAUDE.md) — Developer project guide
- [TEST_PLAN.md](TEST_PLAN.md) — Comprehensive test plan
- [EXECUTION_PLAN.md](EXECUTION_PLAN.md) — Build execution plan
- [Calculator_Research.md](Calculator_Research.md) — Montessori-informed design research

## Building a .app Bundle

A convenience script is included to bundle the app as a standalone macOS `.app`:

```bash
./build-app.sh
```

This creates `SundialCalculator.app` with a proper `Info.plist` that you can double-click to launch or move to `/Applications`.

## Future: iOS Version

An iOS version targeting dyscalculia support is planned with interactive manipulatives, Construct mode, and Core Data storage. See [Calculator_Research.md](Calculator_Research.md) for the full design specification.

## License

All rights reserved.
