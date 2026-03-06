# Sundial Calculator (macOS) — Comprehensive Test Plan

## Overview
This test plan covers the Sundial Calculator macOS app: a dual-output calculator for senior executive knowledge workers. Tests are organized by component and priority. Each test has a unique ID, verifiable expected outcome, and pass/fail criteria.

## How to Run

### Automated Tests (Swift Testing)
```bash
swift test
```
All tests in `Tests/SundialCalculatorTests/` run automatically. They cover the computation engine exhaustively.

### Manual Tests
Follow the procedures below. Launch the app with `swift run` and execute each test case.

---

## 1. Computation Engine (Automated — `CalculatorEngineTests.swift`)

| ID | Test | Input | Expected Output | Status |
|----|-------|-------|-----------------|--------|
| CE-01 | Integer addition | `2 + 3` | `5` | Auto |
| CE-02 | Zero addition | `0 + 0` | `0` | Auto |
| CE-03 | Large addition | `100 + 200` | `300` | Auto |
| CE-04 | Decimal addition | `1.5 + 2.5` | `4.0` | Auto |
| CE-05 | Subtraction (positive result) | `5 − 3` | `2` | Auto |
| CE-06 | Subtraction (ASCII minus) | `5 - 3` | `2` | Auto |
| CE-07 | Subtraction (negative result) | `3 − 5` | `-2` | Auto |
| CE-08 | Multiplication | `4 × 5` | `20` | Auto |
| CE-09 | Multiplication (ASCII) | `4 * 5` | `20` | Auto |
| CE-10 | Multiplication by zero | `0 × 100` | `0` | Auto |
| CE-11 | Decimal multiplication | `2.5 × 4` | `10` | Auto |
| CE-12 | Division | `10 ÷ 2` | `5` | Auto |
| CE-13 | Division (ASCII) | `10 / 2` | `5` | Auto |
| CE-14 | Division (decimal result) | `7 ÷ 2` | `3.5` | Auto |
| CE-15 | Zero divided | `0 ÷ 5` | `0` | Auto |
| CE-16 | Precedence: add × | `2 + 3 × 4` | `14` | Auto |
| CE-17 | Precedence: × add | `2 × 3 + 4` | `10` | Auto |
| CE-18 | Precedence: sub × | `10 − 2 × 3` | `4` | Auto |
| CE-19 | Precedence: ÷ add | `10 ÷ 2 + 3` | `8` | Auto |
| CE-20 | Parentheses (add then ×) | `(2 + 3) × 4` | `20` | Auto |
| CE-21 | Parentheses (× then add) | `2 × (3 + 4)` | `14` | Auto |
| CE-22 | Nested parentheses | `(10 − 2) × (3 + 1)` | `32` | Auto |
| CE-23 | Double parentheses | `((2 + 3))` | `5` | Auto |
| CE-24 | Unary minus | `-5` | `-5` | Auto |
| CE-25 | Unary minus in expr | `-5 + 3` | `-2` | Auto |
| CE-26 | Inline negative | `3 + -2` | `1` | Auto |
| CE-27 | Standalone percent | `50%` | `0.5` | Auto |
| CE-28 | Percent as 100% | `100%` | `1.0` | Auto |
| CE-29 | Percent as 25% | `25%` | `0.25` | Auto |
| CE-30 | Add percent context | `200 + 10%` | `220` | Auto |
| CE-31 | Subtract percent context | `100 − 25%` | `75` | Auto |
| CE-32 | Division by zero error | `5 ÷ 0` | `divisionByZero` | Auto |
| CE-33 | Empty expression error | ` ` | `emptyExpression` | Auto |
| CE-34 | Mismatched paren (open) | `(2 + 3` | `mismatchedParentheses` | Auto |
| CE-35 | Mismatched paren (close) | `2 + 3)` | `mismatchedParentheses` | Auto |
| CE-36 | Invalid characters | `abc` | `invalidExpression` | Auto |
| CE-37 | Complex chained | `(100 + 50) × 2 ÷ 3` | `100` | Auto |
| CE-38 | Sum series | `1 + 2 + 3 + 4 + 5` | `15` | Auto |
| CE-39 | Repeated multiply | `10 × 10 × 10` | `1000` | Auto |
| CE-40 | Large number add | `999999 + 1` | `1000000` | Auto |
| CE-41 | Large number multiply | `1000000 × 1000` | `1000000000` | Auto |
| CE-42 | Integer formatting | `42` formatted | `"42"` | Auto |
| CE-43 | Decimal formatting | `3.14` formatted | `"3.14"` | Auto |

---

## 2. UI — Display & Input (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| UI-01 | App launches | Run `swift run` | Window appears with keypad, display, history sidebar, visual answer panel | |
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

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| VA-01 | Shows after evaluation | Evaluate "48 + 17" | Visual answer panel appears with number line | |
| VA-02 | Number line mode | Select "Number Line" picker, evaluate "10 + 5" | Line shows markers at 10 and 15, with +5 arc | |
| VA-03 | Place Value mode | Select "Place Value", evaluate "1234 + 1" | Breakdown shows 1000 + 200 + 30 + 5 = 1235 | |
| VA-04 | Proportion mode | Select "Proportion", evaluate "50 + 50" | Bar chart shows two segments composing 100 | |
| VA-05 | Toggle visual panel | Click chart icon in toolbar | Visual panel hides/shows | |
| VA-06 | Visual updates on new calc | Evaluate "5 + 3", then "10 × 2" | Visual updates to show new result | |
| VA-07 | Negative result | Evaluate "3 − 10" | Visual handles negative result without crash | |
| VA-08 | Zero result | Evaluate "5 − 5" | Visual handles zero result gracefully | |

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

---

## 6. Keyboard Shortcuts (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| KS-01 | Number keys | Press 0-9 | Digits appear in expression | |
| KS-02 | Operator keys | Press +, -, *, / | Operators appear in expression | |
| KS-03 | Enter to evaluate | Type "5+3", press Enter | Evaluates to 8 | |
| KS-04 | Escape to clear | Type digits, press Escape | Expression clears | |
| KS-05 | Delete to backspace | Type "123", press Delete | Shows "12" | |
| KS-06 | Decimal point | Press "." | Decimal appears | |
| KS-07 | Parentheses | Press ( and ) | Parentheses appear | |
| KS-08 | Percent | Press % | Percent appended | |
| KS-09 | Cmd+C copy | Evaluate result, press Cmd+C | Result copied to clipboard | |
| KS-10 | Cmd+Shift+V visual | Press Cmd+Shift+V | Visual panel toggles | |

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
| AC-07 | Dark mode | Switch macOS to Dark Mode | All UI elements visible, no contrast issues | |
| AC-08 | Light mode | Switch macOS to Light Mode | All UI elements visible, correct colors | |

---

## 8. Edge Cases & Robustness (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| EC-01 | Very large result | Evaluate "999999999 × 999999999" | Displays result without crash, may use scientific notation | |
| EC-02 | Very small decimal | Evaluate "1 ÷ 1000000" | Shows "0.000001" or scientific notation | |
| EC-03 | Repeated equals | Evaluate "5 + 3", press = again | No crash, no change (expression empty) | |
| EC-04 | Rapid input | Type very quickly "123+456=" | Correctly shows 579 | |
| EC-05 | Leading decimal | Enter ".5 + .5" | Result is 1 | |
| EC-06 | Multiple operators | Enter "5 + + 3" | Handles gracefully (error or second + replaces first) | |
| EC-07 | Empty evaluate | Press = with empty expression | Nothing happens, no crash | |
| EC-08 | History overflow | Perform 50+ calculations | History scrolls, no performance degradation | |
| EC-09 | Window resize | Resize window to minimum | Layout adapts, no clipping of essential controls | |
| EC-10 | Window resize large | Maximize window | Layout fills space appropriately | |

---

## 9. Visual Regression Checks (Manual)

| ID | Test | Procedure | Expected Outcome | Pass/Fail |
|----|-------|-----------|-------------------|-----------|
| VR-01 | Button alignment | Inspect keypad grid | All buttons same size, evenly spaced | |
| VR-02 | Button colors | Inspect keypad | Digits: neutral, Operators: orange, Equals: blue | |
| VR-03 | History empty state | Launch fresh | Centered "No calculations yet" text | |
| VR-04 | Display alignment | Enter expression and result | Expression right-aligned, result right-aligned below | |
| VR-05 | Visual answer sizing | Toggle all 3 visual types | Each fills panel without overflow or underflow | |

---

## 10. Automated User Scenario Tests (`UserScenarioTests.swift`)

In addition to the engine tests above, 87 automated user-scenario tests cover end-to-end workflows through the ViewModel. These simulate real button presses and keyboard input.

| Suite | Tests | What it covers |
|-------|-------|----------------|
| UC1: Quick Meeting Math | 4 | Button + keyboard arithmetic |
| UC2: Percentage Calculations | 7 | Tips, tax, discounts, margins, YoY growth |
| UC3: Chained Calculations | 3 | Continue from previous result |
| UC4: Memory Functions | 7 | M+, M−, MR, MC, accumulation, edge cases |
| UC5: Financial Calculations | 5 | Project costs, blended rates, revenue, markup |
| UC6: Error Recovery | 8 | Backspace, clear, error-then-type, all-clear |
| UC7: History | 5 | Order, recall, clear, error exclusion, expression text |
| UC8: Large Numbers | 5 | Millions, billions, formatting |
| UC9: Keyboard-Only Workflow | 5 | Full workflow without mouse |
| UC10: Decimal Precision | 5 | Currency amounts, double-decimal guard, leading decimal |
| UC11: Toggle Sign | 2 | Profit/loss switching |
| UC12: Complex Expressions | 4 | Nested parens, implicit multiply, deep nesting |
| UC13: Visual Answer State | 5 | Operand tracking, type switching, panel toggle |
| UC14: Edge Cases | 8 | Empty eval, repeated =, division by zero, negative, zero |
| UC15: Copy Result | 3 | State verification for clipboard |
| UC16: Formatting | 3 | Integer, decimal, scientific notation |
| UC17: Power / Exponentiation | 5 | Square, cube, compound interest, precedence |
| UC18: Square Root | 3 | √144, √2, √ in expression with precedence |

---

## 11. Quality Gap Tests (`QualityGapTests.swift`)

Tests derived from interprocedural code analysis applying structured verification principles (arxiv 2603.01896v1). Each test targets a specific gap identified in the audit.

| Suite | Tests | What it covers |
|-------|-------|----------------|
| QG1: NaN/Infinity — Domain Errors | 8 | √(negative), (-2)^0.5, 10^1000 overflow, NaN/Infinity formatting, 0^0 |
| QG2: Error Recovery — Operator After Error | 6 | Operator/percent/power/√/toggleSign after error clears broken expression |
| QG3: Percent Operand Extraction | 3 | Visual answer shows resolved percent (20, not 10 for "200+10%") |
| QG4: IEEE 754 Display Precision | 5 | 0.1+0.2 displays "0.3", large integers display without scientific notation |
| QG5: Backspace Edge Cases | 3 | Backspace after √, ^, % |
| QG6: Chained Operations Robustness | 2 | Error-digit-operator recovery, multiple sequential errors |

---

## Test Execution Tracking

| Run Date | Automated Total | Pass | Fail | Notes |
|-----------|----------------|------|------|-------|
| 2026-03-05 | 107 | 107 | 0 | All 19 suites pass |
| 2026-03-05 | 134 | 134 | 0 | All 25 suites pass (quality hardening) |

## Running the Automated Suite

```bash
cd /Users/andydup/Downloads/Development/Sundial_Calculator
swift test
```

Expected: 134 tests across 25 suites, all pass.

## Re-running After Changes

After any code change:
1. Run `swift build` to verify compilation
2. Run `swift test` to verify all 134 automated tests pass
3. Run `swift run` and execute relevant manual tests from sections 2–9
4. Update the tracking table above
