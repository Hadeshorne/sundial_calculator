# Sundial Calculator (macOS) — Comprehensive Test Plan

## Overview

This test plan covers the Sundial Calculator macOS app: a dual-output calculator for senior executive knowledge workers. Tests are organized by component and priority. Each test has a unique ID, verifiable expected outcome, and pass/fail criteria.

**Automated**: 141 tests across 26 suites (Swift Testing framework)
**Manual**: 73 test cases across 8 sections

## How to Run

### Automated Tests (Swift Testing)
```bash
swift test
```
All tests in `Tests/SundialCalculatorTests/` run automatically. Three test files cover the computation engine, ViewModel workflows, and quality gap regressions.

### Manual Tests
Launch the app with `swift run` and execute each test case. Mark Pass/Fail in the tables below.

---

## 1. Computation Engine (Automated — `CalculatorEngineTests.swift`)

20 test functions organized into 9 groups. Each test function may contain multiple assertions.

### 1.1 Basic Arithmetic (4 tests)

| ID | Test Function | Assertions | Key Inputs | Expected |
|----|---------------|------------|------------|----------|
| CE-01 | `addition()` | 4 | `2+3`, `0+0`, `100+200`, `1.5+2.5` | 5, 0, 300, 4.0 |
| CE-02 | `subtraction()` | 4 | `5−3`, `5-3` (ASCII), `3−5`, `0−0` | 2, 2, -2, 0 |
| CE-03 | `multiplication()` | 4 | `4×5`, `4*5` (ASCII), `0×100`, `2.5×4` | 20, 20, 0, 10 |
| CE-04 | `division()` | 4 | `10÷2`, `10/2` (ASCII), `7÷2`, `0÷5` | 5, 5, 3.5, 0 |

### 1.2 Order of Operations (2 tests)

| ID | Test Function | Assertions | Key Inputs | Expected |
|----|---------------|------------|------------|----------|
| CE-05 | `precedence()` | 4 | `2+3×4`, `2×3+4`, `10−2×3`, `10÷2+3` | 14, 10, 4, 8 |
| CE-06 | `parentheses()` | 4 | `(2+3)×4`, `2×(3+4)`, `(10−2)×(3+1)`, `((2+3))` | 20, 14, 32, 5 |

### 1.3 Negative Numbers (1 test)

| ID | Test Function | Assertions | Key Inputs | Expected |
|----|---------------|------------|------------|----------|
| CE-07 | `unaryMinus()` | 3 | `-5`, `-5+3`, `3+-2` | -5, -2, 1 |

### 1.4 Decimals (1 test)

| ID | Test Function | Assertions | Key Inputs | Expected |
|----|---------------|------------|------------|----------|
| CE-08 | `decimals()` | 3 | `0.1+0.2`, `3.14×2`, `10.5÷3` | ≈0.3, 6.28, 3.5 |

### 1.5 Percentage (2 tests)

| ID | Test Function | Assertions | Key Inputs | Expected |
|----|---------------|------------|------------|----------|
| CE-09 | `standalonePercent()` | 3 | `50%`, `100%`, `25%` | 0.5, 1.0, 0.25 |
| CE-10 | `percentInContext()` | 2 | `200+10%`, `100−25%` | 220, 75 |

### 1.6 Error Handling (4 tests)

| ID | Test Function | Assertions | Key Inputs | Expected Error |
|----|---------------|------------|------------|----------------|
| CE-11 | `divisionByZero()` | 1 | `5÷0` | `divisionByZero` |
| CE-12 | `emptyExpression()` | 2 | `""`, `"   "` | `emptyExpression` |
| CE-13 | `mismatchedParens()` | 2 | `(2+3`, `2+3)` | `mismatchedParentheses` |
| CE-14 | `invalidExpression()` | 1 | `abc` | `invalidExpression` |

### 1.7 Tokenizer (2 tests)

| ID | Test Function | Assertions | Key Inputs | Expected |
|----|---------------|------------|------------|----------|
| CE-15 | `tokenize()` | 1 | `2 + 3` | `[.number(2), .op(.add), .number(3)]` |
| CE-16 | `tokenizeParens()` | 1 | `(2 + 3) × 4` | 7-token sequence with parens |

### 1.8 Formatting (2 tests)

| ID | Test Function | Assertions | Key Inputs | Expected |
|----|---------------|------------|------------|----------|
| CE-17 | `formatIntegers()` | 4 | 42, 0, -7, 1000000 | "42", "0", "-7", "1000000" |
| CE-18 | `formatDecimals()` | 2 | 3.14, 0.5 | "3.14", "0.5" |

### 1.9 Complex Expressions & Large Numbers (2 tests)

| ID | Test Function | Assertions | Key Inputs | Expected |
|----|---------------|------------|------------|----------|
| CE-19 | `complex()` | 3 | `(100+50)×2÷3`, `1+2+3+4+5`, `10×10×10` | 100, 15, 1000 |
| CE-20 | `largeNumbers()` | 2 | `999999+1`, `1000000×1000` | 1000000, 1000000000 |

---

## 2. UI — Display & Input (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| UI-01 | App launches | Run `swift run` | Window appears (780×560) with keypad, display, history sidebar, visual answer panel | |
| UI-02 | Digit entry via click | Click buttons 1, 2, 3 | Display shows "123" in expression field | |
| UI-03 | Digit entry via keyboard | Type "456" on keyboard | Display shows "456" in expression field | |
| UI-04 | Operator via click | Enter "5", click "+", enter "3" | Expression shows "5 + 3" | |
| UI-05 | Operator via keyboard | Type "5+3" | Expression shows "5 + 3" | |
| UI-06 | Evaluate via = button | Enter "5 + 3", click = | Result shows "8", expression clears | |
| UI-07 | Evaluate via Enter key | Enter "5 + 3", press Enter | Result shows "8" | |
| UI-08 | Clear button | Enter digits, click C | Expression clears, result clears | |
| UI-09 | Clear via Escape key | Enter digits, press Escape | Expression clears | |
| UI-10 | Backspace button | Enter "123", click ⌫ | Expression shows "12" | |
| UI-11 | Backspace via Delete key | Enter "123", press Delete | Expression shows "12" | |
| UI-12 | Decimal entry | Click "1", ".", "5" | Expression shows "1.5" | |
| UI-13 | No double decimal | Enter "1.5", click "." | No second decimal added | |
| UI-14 | Toggle sign | Enter "5", click ± | Expression shows "-5" or negates properly | |
| UI-15 | Error display | Enter "5 ÷ 0", press = | Red error message "Cannot divide by zero" | |
| UI-16 | Error clears on input | See UI-15, then press "1" | Error disappears, expression shows "1" | |
| UI-17 | Result chaining | Evaluate "2 + 3" = 5, then press "+" | Expression starts with "5 +" | |
| UI-18 | Large result display | Enter "999999999 + 1", press = | Result fits in display, no clipping | |
| UI-19 | Parentheses via buttons | Click "(", "2", "+", "3", ")", "×", "4" | Expression: "(2 + 3) × 4" | |
| UI-20 | Percent button | Enter "200 + 10", click % | Expression shows "200 + 10%" | |
| UI-21 | Power button | Enter "5", click ^ | Expression shows "5 ^ " | |
| UI-22 | Square root button | Click √ | Expression shows "√" | |
| UI-23 | Implicit multiply | Enter "5", click "(" | Expression shows "5 × (" or equivalent implicit multiply | |

---

## 3. UI — History Sidebar (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| HI-01 | Empty state | Launch app | History shows "No calculations yet" | |
| HI-02 | Entry appears | Evaluate "2 + 3" | History shows "2 + 3 = 5" entry | |
| HI-03 | Multiple entries | Evaluate 3 calculations | All 3 appear, newest first | |
| HI-04 | Recall from history | Click a history entry | Expression and result populate from that entry | |
| HI-05 | Clear history | Click "Clear" in history header | All entries removed, empty state shows | |
| HI-06 | Toggle sidebar | Click sidebar toggle button in toolbar | History sidebar hides/shows | |

---

## 4. UI — Visual Answer Panel (Manual)

Six visual answer types: Number Line, Place Value Breakdown, Proportion Bar, Order of Magnitude, Factor Ratio, Area Grid.

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| VA-01 | Shows after evaluation | Evaluate "48 + 17" | Visual answer panel appears with default type | |
| VA-02 | Number Line | Select "Number Line" picker, evaluate "10 + 5" | Line shows markers at 10 and 15, with +5 arc | |
| VA-03 | Place Value Breakdown | Select "Place Value", evaluate "1234 + 1" | Breakdown shows 1000 + 200 + 30 + 5 = 1235 | |
| VA-04 | Proportion Bar | Select "Proportion", evaluate "50 + 50" | Bar chart shows two segments composing 100 | |
| VA-05 | Order of Magnitude | Select "Order of Magnitude", evaluate "500 × 200" | Logarithmic scale showing result magnitude | |
| VA-06 | Factor Ratio | Select "Factor Ratio", evaluate "12 × 5" | Factor/ratio comparison bars for operands | |
| VA-07 | Area Grid | Select "Area Grid", evaluate "6 × 8" | Grid visualization showing 6×8=48 | |
| VA-08 | Toggle visual panel | Click chart icon in toolbar (or Cmd+Shift+V) | Visual panel hides/shows | |
| VA-09 | Visual updates on new calc | Evaluate "5 + 3", then "10 × 2" | Visual updates to show new result | |
| VA-10 | Negative result | Evaluate "3 − 10" | Visual handles negative result without crash | |
| VA-11 | Zero result | Evaluate "5 − 5" | Visual handles zero result gracefully | |
| VA-12 | Type picker persists | Select "Area Grid", evaluate two different expressions | Area Grid stays selected across calculations | |

---

## 5. Memory Functions (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| MF-01 | Memory add | Evaluate "42", click M+ | Memory indicator shows "M: 42" | |
| MF-02 | Memory accumulate | M+ with 42, evaluate "8", M+ | Memory shows "M: 50" | |
| MF-03 | Memory subtract | M+ with 100, evaluate "30", M− | Memory shows "M: 70" | |
| MF-04 | Memory recall | Store 42, clear, click MR | "42" appears in expression | |
| MF-05 | Memory clear | Store value, click MC | Memory indicator disappears | |
| MF-06 | No memory indicator | App launch, no M+ pressed | No "M:" indicator visible | |
| MF-07 | Memory menu shortcuts | Use Calculator menu > Memory commands | Cmd+Shift+A (M+), Cmd+Shift+C (MC) work from menu bar | |

---

## 6. Keyboard Shortcuts (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| KS-01 | Number keys | Press 0-9 | Digits appear in expression | |
| KS-02 | Operator keys (+, -, *, /) | Press +, -, *, / | Operators appear in expression (displayed as +, −, ×, ÷) | |
| KS-03 | Power key (^) | Press ^ | " ^ " appended to expression | |
| KS-04 | Enter to evaluate | Type "5+3", press Enter | Evaluates to 8 | |
| KS-05 | Escape to clear | Type digits, press Escape | Expression clears | |
| KS-06 | Delete to backspace | Type "123", press Delete | Shows "12" | |
| KS-07 | Decimal point | Press "." | Decimal appears | |
| KS-08 | Parentheses | Press ( and ) | Parentheses appear | |
| KS-09 | Percent | Press % | Percent appended | |
| KS-10 | Cmd+C copy result | Evaluate result, press Cmd+C | Result copied to clipboard | |
| KS-11 | Cmd+Shift+E copy expression | Enter "5+3", press Cmd+Shift+E | Expression copied to clipboard | |
| KS-12 | Cmd+V paste | Copy "123" to clipboard, press Cmd+V in app | "123" appended to expression (sanitized) | |
| KS-13 | Cmd+Shift+V toggle visual | Press Cmd+Shift+V | Visual answer panel toggles | |

---

## 7. Accessibility (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| AC-01 | VoiceOver digit buttons | Enable VoiceOver, navigate to keypad | Each button announces its digit/function | |
| AC-02 | VoiceOver result | Evaluate "5 + 3", navigate to result | Announces "Result: 8" | |
| AC-03 | VoiceOver expression | Enter expression, navigate to display | Announces "Expression: 5 + 3" | |
| AC-04 | VoiceOver history | Navigate to history entry | Announces expression and result | |
| AC-05 | VoiceOver visual answer | Navigate to visual panel | Announces description (e.g., "Number line showing...") | |
| AC-06 | Full keyboard navigation | Tab through all controls | All interactive elements reachable | |
| AC-07 | Dark Mode | Switch macOS to Dark Mode | All UI elements visible, no contrast issues | |
| AC-08 | Light Mode | Switch macOS to Light Mode | All UI elements visible, correct colors | |

---

## 8. Edge Cases & Robustness (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| EC-01 | Very large result | Evaluate "999999999 × 999999999" | Displays result without crash | |
| EC-02 | Very small decimal | Evaluate "1 ÷ 1000000" | Shows "1e-06" (scientific notation) | |
| EC-03 | Repeated equals | Evaluate "5 + 3", press = again | No crash, no change (expression empty) | |
| EC-04 | Rapid input | Type very quickly "123+456=" | Correctly shows 579 | |
| EC-05 | Leading decimal | Enter ".5 + .5" | Result is 1 | |
| EC-06 | Multiple operators | Enter "5 + + 3" | Handles gracefully (error or second + replaces first) | |
| EC-07 | Empty evaluate | Press = with empty expression | Nothing happens, no crash | |
| EC-08 | History overflow | Perform 50+ calculations | History scrolls, no performance degradation | |
| EC-09 | Window resize min | Resize window to minimum (600×500) | Layout adapts, no clipping of essential controls | |
| EC-10 | Window resize max | Maximize window | Layout fills space appropriately | |
| EC-11 | Power overflow | Evaluate "10 ^ 1000" | Shows "Undefined result" error | |
| EC-12 | Square root negative | Evaluate "√(-4)" | Shows "Undefined result" error | |
| EC-13 | 0^0 convention | Evaluate "0 ^ 0" | Result is "1" (IEEE 754) | |

---

## 9. Visual Regression Checks (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| VR-01 | Button alignment | Inspect keypad grid | All buttons same size, evenly spaced | |
| VR-02 | Button colors | Inspect keypad | Digits: neutral, Operators: orange, Equals: blue | |
| VR-03 | History empty state | Launch fresh | Centered "No calculations yet" text | |
| VR-04 | Display alignment | Enter expression and result | Expression right-aligned, result right-aligned below | |
| VR-05 | Visual answer sizing | Toggle all 6 visual types | Each fills panel without overflow or underflow | |
| VR-06 | Memory indicator | M+ a value | "M:" indicator appears in correct position | |

---

## 10. Automated User Scenario Tests (`UserScenarioTests.swift`)

94 automated tests across 19 use-case suites. Each test simulates real button-press / keyboard sequences through the ViewModel.

| Suite | Tests | What it covers |
|-------|-------|----------------|
| UC1: Quick Meeting Math | 4 | Button + keyboard arithmetic (+, −, ×, ÷) |
| UC2: Percentage Calculations | 7 | Tips, tax, discounts, margins, YoY growth |
| UC3: Chained Calculations | 3 | Continue from previous result (+, ×, ÷) |
| UC4: Memory Functions | 7 | M+, M−, MR, MC, accumulation, empty recall, no-result M+ |
| UC5: Financial Calculations | 5 | Project costs, blended rates, revenue, markup, quarterly |
| UC6: Error Recovery | 8 | Backspace, clear, error-then-type, all-clear, fix operator, multiple backspaces, backspace-empty |
| UC7: History | 5 | Order, recall, clear, error exclusion, expression text |
| UC8: Large Numbers | 5 | Millions, billions, formatting |
| UC9: Keyboard-Only Workflow | 5 | Full workflow without mouse (calc, parens, %, decimal, backspace) |
| UC10: Decimal Precision | 5 | Currency amounts, double-decimal guard, leading decimal, decimal after operator |
| UC11: Toggle Sign | 2 | Profit/loss switching (result and expression) |
| UC12: Complex Expressions | 4 | Nested parens, multiple paren groups, implicit multiply, deep nesting |
| UC13: Visual Answer State | 5 | Operand tracking, type switching, panel toggle, multiply operands, complex-expr operands |
| UC14: Edge Cases | 8 | Empty eval, repeated =, division by zero, mismatched parens, long expr, negative, zero, ×0 |
| UC15: Copy Result | 3 | State verification: result ready, expression ready, empty state |
| UC16: Formatting | 3 | Integer, decimal, scientific notation display |
| UC17: Power / Exponentiation | 5 | Square, cube, compound interest, precedence (2×3^2=18), parens with power |
| UC18: Square Root | 3 | √144=12, √2≈1.4142, √25+3=8 (precedence) |
| UC19: Copy Expression & Paste | 7 | Copy expression, copy empty, paste valid, paste sanitizes, paste appends, paste clears error, paste empty pasteboard |

---

## 11. Quality Gap Tests (`QualityGapTests.swift`)

27 tests across 6 suites. Derived from interprocedural code analysis applying structured verification principles (arxiv 2603.01896v1). Each test targets a specific gap identified in the audit.

| Suite | Tests | What it covers |
|-------|-------|----------------|
| QG1: NaN/Infinity — Domain Errors | 8 | √(negative), √(negative expr), (-2)^0.5, 10^1000 overflow, NaN formatting → "Error", Infinity → "Overflow", -Infinity → "-Overflow", 0^0=1 |
| QG2: Error Recovery — Operator After Error | 6 | Operator/percent/power/√/toggleSign after error clears broken expression, √(negative) via ViewModel |
| QG3: Percent Operand Extraction | 3 | Visual answer shows resolved percent: 200+10%→right=20, 1200−20%→right=240, 200×15%→right=0.15 |
| QG4: IEEE 754 Display Precision | 5 | 0.1+0.2 → "0.3", 0.1+0.2+0.3 → "0.6", 1.1×1.1 → "1.21", large integer accuracy, tiny decimal → "1e-06" |
| QG5: Backspace Edge Cases | 3 | Backspace after √, ^, % removes the operator cleanly |
| QG6: Chained Operations Robustness | 2 | Error-digit-operator recovery, multiple sequential errors don't corrupt state |

---

## Test Summary

| Category | File | Tests | Type |
|----------|------|-------|------|
| Engine | `CalculatorEngineTests.swift` | 20 | Automated |
| User Scenarios | `UserScenarioTests.swift` | 94 | Automated |
| Quality Gaps | `QualityGapTests.swift` | 27 | Automated |
| **Automated Total** | | **141** | |
| UI Display & Input | Manual | 23 | Manual |
| History Sidebar | Manual | 6 | Manual |
| Visual Answer Panel | Manual | 12 | Manual |
| Memory Functions | Manual | 7 | Manual |
| Keyboard Shortcuts | Manual | 13 | Manual |
| Accessibility | Manual | 8 | Manual |
| Edge Cases | Manual | 13 | Manual |
| Visual Regression | Manual | 6 | Manual |
| **Manual Total** | | **88** | |
| **Grand Total** | | **229** | |

---

## Test Execution Tracking

| Run Date | Automated Total | Pass | Fail | Notes |
|-----------|----------------|------|------|-------|
| 2026-03-05 | 107 | 107 | 0 | All 19 suites pass (initial build) |
| 2026-03-05 | 134 | 134 | 0 | All 25 suites pass (quality hardening + UC19) |
| 2026-03-07 | 141 | 141 | 0 | All 26 suites pass (verified, test plan updated) |

---

## Running the Automated Suite

```bash
cd /Users/andydup/Downloads/Development/Sundial_Calculator
swift test
```

Expected: **141 tests across 26 suites**, all pass.

To run a specific suite:
```bash
swift test --filter "CalculatorEngine"
swift test --filter "UC1"
swift test --filter "QG1"
```

## Re-running After Changes

After any code change:
1. Run `swift build` to verify compilation
2. Run `swift test` to verify all 141 automated tests pass
3. Run `swift run` and execute relevant manual tests from sections 2–9
4. Update the tracking table above
