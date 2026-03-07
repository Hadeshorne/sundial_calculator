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
- **Operator precedence** — correct PEMDAS/BODMAS order of operations
- **Parentheses** — group sub-expressions
- **Power** — `5^2` = 25, `1.05^10` ≈ 1.629 (compound interest)
- **Square root** — `√144` = 12, `√25 + 3` = 8
- **Percentage** — standalone (`50%` = 0.5) and contextual (`200 + 10%` = 220)
- **Memory** — M+, M−, MR, MC for running totals

### Visual Answer Panel
Every result includes an optional visual check — choose from six types:
- **Number Line** — shows operands and result on a scaled line with jump arcs
- **Place Value** — decomposes results into thousands, hundreds, tens, ones with color-coded blocks
- **Proportion** — bar visualization showing how operands compose the result
- **Magnitude** — logarithmic scale showing where numbers fall across orders of magnitude
- **Factor** — side-by-side bars with ratio annotations and percentage change
- **Area** — grid visualization for multiplication, division, and power operations

### History Sidebar
- All calculations saved in session
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
| Cmd+Shift+V | Toggle visual panel |
| Cmd+Shift+C | Clear expression |

### Accessibility
- VoiceOver labels on all interactive elements
- Full keyboard navigation
- Dark Mode and Light Mode support
- High-contrast button styling

## Design Principles

Grounded in [Montessori-informed design research](Calculator_Research.md):

- **Visual verification** — every result can be visually checked for magnitude and structure
- **Cognitive load reduction** — clean UI, progressive disclosure, no clutter
- **Control of error** — visual answers help catch order-of-magnitude mistakes
- **Freedom within limits** — choose from 6 visual types, each suited to different operations

## Architecture

- SwiftUI macOS app built with Swift Package Manager
- MVVM pattern: `CalculatorViewModel` → `CalculatorEngine`
- Pure Swift computation engine (no UI dependencies, fully unit-tested)
- Visual renderers are interchangeable SwiftUI views
- 141 automated tests across 26 suites

## Project Structure

```
Sources/SundialCalculator/
├── SundialCalculatorApp.swift      # App entry point
├── Models/                         # Engine + data models
├── ViewModels/                     # State management
├── Views/                          # UI components
└── VisualAnswers/                  # Visual renderers
Tests/SundialCalculatorTests/       # 141 automated tests
```

## Testing

See [TEST_PLAN.md](TEST_PLAN.md) for the comprehensive test plan.

```bash
swift test   # Runs 141 automated tests across 26 suites
swift run    # Launch app for manual testing
```

## Documentation

- [CHEATSHEET.md](CHEATSHEET.md) — User manual for first-time users
- [TEST_PLAN.md](TEST_PLAN.md) — Comprehensive test plan
- [EXECUTION_PLAN.md](EXECUTION_PLAN.md) — Build execution plan

## Future: iOS Version

An iOS version targeting dyscalculia support is planned with interactive manipulatives, Construct mode, and Core Data storage. See `Calculator_Research.md` for the full design specification.

## License

All rights reserved.
