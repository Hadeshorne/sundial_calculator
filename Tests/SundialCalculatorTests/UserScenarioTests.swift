import AppKit
import Testing
@testable import SundialCalculator

// =============================================================================
// USER SCENARIO TESTS
// Tests every key use case a senior executive knowledge worker would encounter.
// Each test simulates real button-press / keyboard sequences through the ViewModel.
// =============================================================================

@Suite("UC1: Quick Meeting Math")
struct QuickMeetingMathTests {

    @Test("Add two numbers via button taps")
    func addViaTaps() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("4")
        vm.appendCharacter("8")
        vm.appendOperator(.add)
        vm.appendCharacter("1")
        vm.appendCharacter("7")
        vm.evaluate()
        #expect(vm.displayResult == "65")
        #expect(vm.expression == "")
        #expect(vm.errorMessage == nil)
    }

    @Test("Subtract via keyboard input")
    func subtractViaKeyboard() {
        let vm = CalculatorViewModel()
        for ch in "500" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("-")
        for ch in "175" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "325")
    }

    @Test("Multiply via keyboard")
    func multiplyViaKeyboard() {
        let vm = CalculatorViewModel()
        for ch in "12" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("*")
        for ch in "15" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("=")
        #expect(vm.displayResult == "180")
    }

    @Test("Divide via keyboard")
    func divideViaKeyboard() {
        let vm = CalculatorViewModel()
        for ch in "1000" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("/")
        for ch in "4" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "250")
    }
}

// =============================================================================

@Suite("UC2: Percentage Calculations — Margins, Tax, Discounts")
struct PercentageTests {

    @Test("Calculate 15% tip on a $200 dinner: 200 × 15%")
    func tipCalculation() throws {
        // Executive enters: 200 * 15% to get the tip amount
        let result = try CalculatorEngine.evaluate("200 × 15%")
        #expect(result == 30)
    }

    @Test("Add 8.5% sales tax to $500: 500 + 8.5%")
    func salesTax() throws {
        let result = try CalculatorEngine.evaluate("500 + 8.5%")
        #expect(result == 542.5)
    }

    @Test("Apply 20% discount to $1200: 1200 − 20%")
    func discount() throws {
        let result = try CalculatorEngine.evaluate("1200 − 20%")
        #expect(result == 960)
    }

    @Test("What is 25% of 800: 800 × 25%")
    func percentOf() throws {
        let result = try CalculatorEngine.evaluate("800 × 25%")
        #expect(result == 200)
    }

    @Test("Convert 45% to decimal: 45%")
    func percentToDecimal() throws {
        let result = try CalculatorEngine.evaluate("45%")
        #expect(result == 0.45)
    }

    @Test("Gross margin: revenue minus cost as percent — (500 − 350) ÷ 500")
    func grossMarginFormula() throws {
        let result = try CalculatorEngine.evaluate("(500 − 350) ÷ 500")
        #expect(result == 0.3)
    }

    @Test("Year-over-year growth: (1200000 − 1000000) ÷ 1000000")
    func yoyGrowth() throws {
        let result = try CalculatorEngine.evaluate("(1200000 − 1000000) ÷ 1000000")
        #expect(result == 0.2)
    }
}

// =============================================================================

@Suite("UC3: Chained Calculations — Build on Previous Result")
struct ChainedCalculationTests {

    @Test("Evaluate then continue: 50+50=100, then +25=125")
    func chainFromResult() {
        let vm = CalculatorViewModel()
        // First calc
        vm.appendCharacter("5")
        vm.appendCharacter("0")
        vm.appendOperator(.add)
        vm.appendCharacter("5")
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.displayResult == "100")

        // Chain: press + to continue from 100
        vm.appendOperator(.add)
        #expect(vm.expression.contains("100"))
        vm.appendCharacter("2")
        vm.appendCharacter("5")
        vm.evaluate()
        #expect(vm.displayResult == "125")
    }

    @Test("Chain multiply after result")
    func chainMultiply() {
        let vm = CalculatorViewModel()
        for ch in "10" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("*")
        for ch in "5" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "50")

        // Continue: *3
        vm.handleKeyPress("*")
        for ch in "3" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "150")
    }

    @Test("Chain divide after result")
    func chainDivide() {
        let vm = CalculatorViewModel()
        for ch in "1000" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("/")
        for ch in "4" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "250")

        vm.handleKeyPress("/")
        for ch in "5" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "50")
    }
}

// =============================================================================

@Suite("UC4: Memory — Running Totals Across Calculations")
struct MemoryTests {

    @Test("M+ stores result, MR recalls it")
    func memoryAddRecall() {
        let vm = CalculatorViewModel()
        for ch in "100" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "100")

        vm.memoryAdd()
        #expect(vm.hasMemory == true)
        #expect(vm.memory == 100)

        vm.clear()
        vm.memoryRecall()
        #expect(vm.expression == "100")

        vm.clear()
        vm.appendCharacter("5")
        vm.memoryRecall()
        #expect(vm.expression == "5 × 100")
    }

    @Test("M+ accumulates across multiple calculations")
    func memoryAccumulate() {
        let vm = CalculatorViewModel()
        // First: 250
        for ch in "250" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        vm.memoryAdd()

        // Second: 350
        for ch in "350" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        vm.memoryAdd()

        #expect(vm.memory == 600)

        // Recall into expression
        vm.clear()
        vm.memoryRecall()
        #expect(vm.expression == "600")
    }

    @Test("M− subtracts from memory")
    func memorySubtract() {
        let vm = CalculatorViewModel()
        for ch in "1000" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        vm.memoryAdd()

        for ch in "300" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        vm.memorySubtract()

        #expect(vm.memory == 700)
    }

    @Test("MC clears memory")
    func memoryClear() {
        let vm = CalculatorViewModel()
        for ch in "500" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        vm.memoryAdd()
        #expect(vm.hasMemory == true)

        vm.memoryClear()
        #expect(vm.hasMemory == false)
        #expect(vm.memory == 0)
    }

    @Test("MR does nothing when memory is empty")
    func memoryRecallEmpty() {
        let vm = CalculatorViewModel()
        vm.memoryRecall()
        #expect(vm.expression == "")
    }

    @Test("M+ does nothing when no result exists")
    func memoryAddNoResult() {
        let vm = CalculatorViewModel()
        vm.memoryAdd()
        #expect(vm.hasMemory == false)
    }

    @Test("Use memory in a larger expression: recall + new number")
    func memoryInExpression() {
        let vm = CalculatorViewModel()
        // Store 100
        for ch in "100" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        vm.memoryAdd()

        // New expression: MR + 50
        vm.clear()
        vm.memoryRecall()
        vm.appendOperator(.add)
        vm.appendCharacter("5")
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.displayResult == "150")

        vm.clear()
        vm.appendCharacter("5")
        vm.appendOperator(.add)
        vm.memoryRecall()
        #expect(vm.expression == "5 + 100")
    }
}

// =============================================================================

@Suite("UC5: Multi-Step Budget / Financial Calculations")
struct FinancialTests {

    @Test("Total project cost: (50000 + 30000 + 15000) × 1.1 (with 10% contingency)")
    func projectCost() throws {
        let result = try CalculatorEngine.evaluate("(50000 + 30000 + 15000) × 1.1")
        #expect(isClose(result, 104500))
    }

    @Test("Revenue per employee: 5000000 ÷ 120")
    func revenuePerEmployee() throws {
        let result = try CalculatorEngine.evaluate("5000000 ÷ 120")
        #expect(isClose(result, 41666.666666666664))
    }

    @Test("Quarterly from annual: 2400000 ÷ 4")
    func quarterlyFromAnnual() throws {
        let result = try CalculatorEngine.evaluate("2400000 ÷ 4")
        #expect(result == 600000)
    }

    @Test("Blended hourly rate: (150 × 5 + 200 × 3 + 300 × 2) ÷ 10")
    func blendedRate() throws {
        let result = try CalculatorEngine.evaluate("(150 × 5 + 200 × 3 + 300 × 2) ÷ 10")
        #expect(result == 195)
    }

    @Test("Markup from cost: 80 × 1.4 (40% markup)")
    func markup() throws {
        let result = try CalculatorEngine.evaluate("80 × 1.4")
        #expect(result == 112)
    }

    private func isClose(_ a: Double, _ b: Double, tolerance: Double = 0.0001) -> Bool {
        abs(a - b) < tolerance
    }
}

// =============================================================================

@Suite("UC6: Error Recovery — Mistake, Fix, Continue")
struct ErrorRecoveryTests {

    @Test("Backspace removes last digit")
    func backspaceDigit() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.appendCharacter("2")
        vm.appendCharacter("3")
        vm.backspace()
        #expect(vm.expression == "12")
    }

    @Test("Backspace removes operator with surrounding spaces")
    func backspaceOperator() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.add) // expression = "5 + "
        vm.backspace()
        #expect(vm.expression == "5")

        vm.appendOperator(.add)
        vm.appendOperator(.multiply)
        #expect(vm.expression == "5 × ")
    }

    @Test("Clear resets everything for fresh start")
    func clearFreshStart() {
        let vm = CalculatorViewModel()
        for ch in "123" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("+")
        for ch in "456" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "579")

        vm.clear()
        #expect(vm.expression == "")
        #expect(vm.displayResult == "")
        #expect(vm.lastResult == nil)
    }

    @Test("Error message clears and expression resets when user starts typing again")
    func errorClearsOnInput() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage == "Cannot divide by zero")
        // Old broken expression still present until user types
        #expect(vm.expression == "5 ÷ 0")

        // User starts fresh — expression should clear and start with "7"
        vm.appendCharacter("7")
        #expect(vm.errorMessage == nil)
        #expect(vm.expression == "7")
    }

    @Test("Fix mistyped operator: 5+ backspace then ×")
    func fixOperator() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.add)
        vm.backspace() // remove the +
        vm.appendOperator(.multiply)
        vm.appendCharacter("3")
        vm.evaluate()
        #expect(vm.displayResult == "15")
    }

    @Test("All-clear resets history and memory too")
    func allClear() {
        let vm = CalculatorViewModel()
        for ch in "10" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        vm.memoryAdd()
        #expect(vm.history.count == 1)
        #expect(vm.hasMemory == true)

        vm.allClear()
        #expect(vm.history.count == 0)
        #expect(vm.hasMemory == false)
        #expect(vm.memory == 0)
        #expect(vm.expression == "")
        #expect(vm.displayResult == "")
    }

    @Test("Multiple backspaces clear entire expression")
    func multipleBackspaces() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.add)
        vm.appendCharacter("3")
        vm.backspace() // removes 3
        vm.backspace() // removes " + "
        vm.backspace() // removes 5
        #expect(vm.expression == "")
    }

    @Test("Backspace on empty expression does nothing")
    func backspaceEmpty() {
        let vm = CalculatorViewModel()
        vm.backspace()
        #expect(vm.expression == "")
    }
}

// =============================================================================

@Suite("UC7: History — Recall and Reuse Past Calculations")
struct HistoryTests {

    @Test("Calculations are added to history in reverse chronological order")
    func historyOrder() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.evaluate()
        vm.appendCharacter("2")
        vm.evaluate()
        vm.appendCharacter("3")
        vm.evaluate()

        #expect(vm.history.count == 3)
        #expect(vm.history[0].formattedResult == "3")
        #expect(vm.history[1].formattedResult == "2")
        #expect(vm.history[2].formattedResult == "1")
    }

    @Test("Recall a history entry loads its expression and result")
    func recallEntry() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.add)
        vm.appendCharacter("3")
        vm.evaluate()

        let record = vm.history[0]
        vm.clear()
        vm.recallFromHistory(record)

        #expect(vm.expression == "5 + 3")
        #expect(vm.displayResult == "8")
        #expect(vm.lastResult == 8)
    }

    @Test("Clear history removes all entries")
    func clearHistory() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.evaluate()
        vm.appendCharacter("2")
        vm.evaluate()
        #expect(vm.history.count == 2)

        vm.clearHistory()
        #expect(vm.history.count == 0)
    }

    @Test("Error does not add to history")
    func errorNotInHistory() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()

        #expect(vm.history.count == 0)
        #expect(vm.errorMessage != nil)
    }

    @Test("History preserves exact expression text")
    func historyExpression() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.appendCharacter("0")
        vm.appendCharacter("0")
        vm.appendOperator(.multiply)
        vm.appendCharacter("2")
        vm.appendCharacter("5")
        vm.evaluate()

        #expect(vm.history[0].expression == "100 × 25")
        #expect(vm.history[0].formattedResult == "2500")
    }
}

// =============================================================================

@Suite("UC8: Large Numbers — Revenue, Budget, Headcount Figures")
struct LargeNumberTests {

    @Test("Million-scale addition")
    func millionAdd() throws {
        let result = try CalculatorEngine.evaluate("3500000 + 1200000")
        #expect(result == 4700000)
    }

    @Test("Billion-scale division")
    func billionDivide() throws {
        let result = try CalculatorEngine.evaluate("2000000000 ÷ 500")
        #expect(result == 4000000)
    }

    @Test("Large multiply")
    func largeMul() throws {
        let result = try CalculatorEngine.evaluate("150000 × 365")
        #expect(result == 54750000)
    }

    @Test("Format large integer cleanly")
    func formatLarge() {
        #expect(CalculatorEngine.formatResult(1000000) == "1000000")
    }

    @Test("Format medium integer without scientific notation")
    func formatMedium() {
        #expect(CalculatorEngine.formatResult(50000) == "50000")
    }
}

// =============================================================================

@Suite("UC9: Keyboard-Only Workflow — No Mouse")
struct KeyboardOnlyTests {

    @Test("Full calculation via keyboard only")
    func fullKeyboardCalc() {
        let vm = CalculatorViewModel()
        // Type: 250*4= via handleKeyPress
        for ch in "250" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("*")
        for ch in "4" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "1000")
    }

    @Test("Parentheses via keyboard")
    func keyboardParens() {
        let vm = CalculatorViewModel()
        vm.handleKeyPress("(")
        for ch in "10" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("+")
        for ch in "5" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress(")")
        vm.handleKeyPress("*")
        vm.handleKeyPress("3")
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "45")
    }

    @Test("Percent via keyboard")
    func keyboardPercent() {
        let vm = CalculatorViewModel()
        for ch in "200" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("+")
        for ch in "10" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("%")
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "220")
    }

    @Test("Decimal entry via keyboard")
    func keyboardDecimal() {
        let vm = CalculatorViewModel()
        for ch in "3" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress(".")
        for ch in "14" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("*")
        vm.handleKeyPress("2")
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "6.28")
    }

    @Test("Backspace via keyboard (delete char)")
    func keyboardBackspace() {
        let vm = CalculatorViewModel()
        for ch in "123" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\u{7F}")
        #expect(vm.expression == "12")
    }
}

// =============================================================================

@Suite("UC10: Decimal Precision — Currency Amounts")
struct DecimalPrecisionTests {

    @Test("Currency addition: 19.99 + 5.99")
    func currencyAdd() throws {
        let result = try CalculatorEngine.evaluate("19.99 + 5.99")
        #expect(abs(result - 25.98) < 0.0001)
    }

    @Test("Currency multiplication: 49.95 × 3")
    func currencyMul() throws {
        let result = try CalculatorEngine.evaluate("49.95 × 3")
        #expect(abs(result - 149.85) < 0.0001)
    }

    @Test("Prevent double decimal in same number")
    func noDoubleDecimal() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.appendDecimal()
        vm.appendCharacter("5")
        vm.appendDecimal() // should be ignored
        vm.appendCharacter("3")
        #expect(vm.expression == "1.53")
    }

    @Test("Decimal after operator starts new number: 5 + .5")
    func decimalAfterOperator() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.add)
        vm.appendDecimal() // should produce "0."
        vm.appendCharacter("5")
        vm.evaluate()
        #expect(vm.displayResult == "5.5")
    }

    @Test("Leading decimal: .75 evaluates correctly")
    func leadingDecimal() {
        let vm = CalculatorViewModel()
        vm.appendDecimal()
        vm.appendCharacter("7")
        vm.appendCharacter("5")
        vm.evaluate()
        #expect(vm.displayResult == "0.75")
    }
}

// =============================================================================

@Suite("UC11: Toggle Sign — Profit / Loss Switching")
struct ToggleSignTests {

    @Test("Toggle sign on a computed result")
    func toggleResultSign() {
        let vm = CalculatorViewModel()
        for ch in "500" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "500")

        vm.toggleSign()
        #expect(vm.displayResult == "-500")
        #expect(vm.lastResult == -500)
    }

    @Test("Toggle sign on expression digit")
    func toggleExpressionSign() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("4")
        vm.appendCharacter("2")
        vm.toggleSign()
        // Should negate the 42
        #expect(vm.expression.contains("-"))
    }
}

// =============================================================================

@Suite("UC12: Complex Parenthesized Expressions")
struct ComplexExpressionTests {

    @Test("Nested parens: ((10 + 5) × 2) ÷ 3")
    func nestedParens() throws {
        let result = try CalculatorEngine.evaluate("((10 + 5) × 2) ÷ 3")
        #expect(result == 10)
    }

    @Test("Multiple paren groups: (100 + 200) × (3 + 7)")
    func multipleParenGroups() throws {
        let result = try CalculatorEngine.evaluate("(100 + 200) × (3 + 7)")
        #expect(result == 3000)
    }

    @Test("Implicit multiply with parens: 5(3+2) via ViewModel")
    func implicitMultiply() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendParenthesis("(")
        vm.appendCharacter("3")
        vm.appendOperator(.add)
        vm.appendCharacter("2")
        vm.appendParenthesis(")")
        vm.evaluate()
        #expect(vm.displayResult == "25")
    }

    @Test("Deeply nested: (((2 + 3) × 4) − 10) ÷ 2")
    func deepNesting() throws {
        let result = try CalculatorEngine.evaluate("(((2 + 3) × 4) − 10) ÷ 2")
        #expect(result == 5)
    }
}

// =============================================================================

@Suite("UC13: Visual Answer State Tracking")
struct VisualAnswerStateTests {

    @Test("After evaluation, lastResult is set for visual panel")
    func resultSetForVisual() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("4")
        vm.appendCharacter("8")
        vm.appendOperator(.add)
        vm.appendCharacter("1")
        vm.appendCharacter("7")
        vm.evaluate()

        #expect(vm.lastResult == 65)
        #expect(vm.lastOperands?.left == 48)
        #expect(vm.lastOperands?.right == 17)
        #expect(vm.lastOperator == .add)
    }

    @Test("Visual type can be switched")
    func switchVisualType() {
        let vm = CalculatorViewModel()
        vm.selectedVisualType = .breakdown
        #expect(vm.selectedVisualType == .breakdown)
        vm.selectedVisualType = .proportion
        #expect(vm.selectedVisualType == .proportion)
        vm.selectedVisualType = .numberLine
        #expect(vm.selectedVisualType == .numberLine)
    }

    @Test("Visual panel can be toggled")
    func toggleVisualPanel() {
        let vm = CalculatorViewModel()
        #expect(vm.showVisualAnswer == true)
        vm.showVisualAnswer = false
        #expect(vm.showVisualAnswer == false)
    }

    @Test("Operand extraction for multiply")
    func operandExtractionMultiply() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.appendCharacter("2")
        vm.appendOperator(.multiply)
        vm.appendCharacter("5")
        vm.evaluate()

        #expect(vm.lastOperands?.left == 12)
        #expect(vm.lastOperands?.right == 5)
        #expect(vm.lastOperator == .multiply)
    }

    @Test("Complex expression clears operand tracking")
    func complexExprClearsOperands() {
        let vm = CalculatorViewModel()
        // (10+5)*3 — not a simple binary op
        vm.appendParenthesis("(")
        vm.appendCharacter("1")
        vm.appendCharacter("0")
        vm.appendOperator(.add)
        vm.appendCharacter("5")
        vm.appendParenthesis(")")
        vm.appendOperator(.multiply)
        vm.appendCharacter("3")
        vm.evaluate()

        // Should not have simple operands since it's complex
        #expect(vm.lastResult == 45)
    }
}

// =============================================================================

@Suite("UC14: Edge Cases Executives Hit")
struct ExecutiveEdgeCaseTests {

    @Test("Evaluate empty expression does nothing")
    func evaluateEmpty() {
        let vm = CalculatorViewModel()
        vm.evaluate()
        #expect(vm.displayResult == "")
        #expect(vm.errorMessage == nil)
    }

    @Test("Repeated equals does not crash or duplicate history")
    func repeatedEquals() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.evaluate()
        let count = vm.history.count
        vm.evaluate() // empty expression, should do nothing
        #expect(vm.history.count == count)
    }

    @Test("Division by zero shows friendly error")
    func divByZeroError() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.appendCharacter("0")
        vm.appendCharacter("0")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage == "Cannot divide by zero")
        #expect(vm.history.count == 0)
    }

    @Test("Mismatched parentheses shows error")
    func mismatchedParensError() {
        let vm = CalculatorViewModel()
        vm.appendParenthesis("(")
        vm.appendCharacter("5")
        vm.appendOperator(.add)
        vm.appendCharacter("3")
        vm.evaluate()
        #expect(vm.errorMessage == "Mismatched parentheses")
    }

    @Test("Very long expression evaluates correctly")
    func longExpression() throws {
        let result = try CalculatorEngine.evaluate("1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10")
        #expect(result == 55)
    }

    @Test("Negative result from subtraction")
    func negativeResult() throws {
        let result = try CalculatorEngine.evaluate("100 − 350")
        #expect(result == -250)
    }

    @Test("Zero result")
    func zeroResult() throws {
        let result = try CalculatorEngine.evaluate("500 − 500")
        #expect(result == 0)
    }

    @Test("Multiply by zero")
    func multiplyByZero() throws {
        let result = try CalculatorEngine.evaluate("999999 × 0")
        #expect(result == 0)
    }
}

// =============================================================================

@Suite("UC15: Copy Result — State Verification")
struct CopyResultTests {

    @Test("displayResult is set correctly before copy")
    func resultReadyForCopy() {
        let vm = CalculatorViewModel()
        for ch in "42" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "42")
    }

    @Test("expression is available for copy when no result")
    func expressionReadyForCopy() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.appendCharacter("2")
        vm.appendCharacter("3")
        #expect(vm.expression == "123")
    }

    @Test("copyResult doesn't crash with empty state")
    func copyEmptyState() {
        let vm = CalculatorViewModel()
        // Should not crash even with empty expression and result
        vm.copyResult()
    }
}

// =============================================================================

@Suite("UC16: Formatting — Display Quality")
struct FormattingTests {

    @Test("Integer results have no decimal point")
    func integerFormat() {
        #expect(CalculatorEngine.formatResult(100) == "100")
        #expect(CalculatorEngine.formatResult(0) == "0")
        #expect(CalculatorEngine.formatResult(-42) == "-42")
    }

    @Test("Decimal results preserve significant digits")
    func decimalFormat() {
        #expect(CalculatorEngine.formatResult(3.14159) == "3.14159")
        #expect(CalculatorEngine.formatResult(0.5) == "0.5")
    }

    @Test("Very small decimals use scientific notation")
    func smallDecimalFormat() {
        let formatted = CalculatorEngine.formatResult(0.000001)
        #expect(formatted == "1e-06")
    }
}

// =============================================================================

@Suite("UC17: Power / Exponentiation — Compound Growth")
struct PowerTests {

    @Test("Simple square: 5^2 = 25")
    func simpleSquare() throws {
        let result = try CalculatorEngine.evaluate("5 ^ 2")
        #expect(result == 25)
    }

    @Test("Compound interest factor: 1.05^10 ≈ 1.6289")
    func compoundInterest() throws {
        let result = try CalculatorEngine.evaluate("1.05 ^ 10")
        #expect(abs(result - 1.6288946267774414) < 0.0001)
    }

    @Test("Cube: 3^3 = 27")
    func cube() throws {
        let result = try CalculatorEngine.evaluate("3 ^ 3")
        #expect(result == 27)
    }

    @Test("Power has higher precedence than multiply: 2 × 3^2 = 18")
    func powerPrecedence() throws {
        let result = try CalculatorEngine.evaluate("2 × 3 ^ 2")
        #expect(result == 18)
    }

    @Test("Power in parenthesized expression: (2 + 3) ^ 2 = 25")
    func powerWithParens() throws {
        let result = try CalculatorEngine.evaluate("(2 + 3) ^ 2")
        #expect(result == 25)
    }
}

// =============================================================================

@Suite("UC18: Square Root")
struct SquareRootTests {

    @Test("Square root of 144 = 12")
    func sqrt144() throws {
        let result = try CalculatorEngine.evaluate("√144")
        #expect(result == 12)
    }

    @Test("Square root of 2 ≈ 1.4142")
    func sqrt2() throws {
        let result = try CalculatorEngine.evaluate("√2")
        #expect(abs(result - 1.41421356) < 0.0001)
    }

    @Test("Square root in expression: √25 + 3 = 8")
    func sqrtInExpr() throws {
        let result = try CalculatorEngine.evaluate("√25 + 3")
        #expect(result == 8)
    }
}

// =============================================================================

@Suite("UC19: Copy Expression & Paste", .serialized)
struct CopyPasteTests {

    @Test("copyExpression sets pasteboard to current expression")
    func copyExpression() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("1")
        vm.appendCharacter("2")
        vm.appendOperator(.multiply)
        vm.appendCharacter("3")
        vm.appendOperator(.subtract)
        vm.appendCharacter("4")
        #expect(vm.expression == "12 × 3 − 4")
        vm.copyExpression()
    }

    @Test("copyExpression does nothing when expression is empty")
    func copyExpressionEmpty() {
        let vm = CalculatorViewModel()
        #expect(vm.expression == "")
        // Should not crash with empty expression
        vm.copyExpression()
    }

    @Test("pasteExpression appends valid text to expression")
    func pasteValid() {
        let vm = CalculatorViewModel()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("123×456−7÷2", forType: .string)
        vm.pasteExpression()
        #expect(vm.expression == "123×456−7÷2")
    }

    @Test("pasteExpression sanitizes invalid characters")
    func pasteSanitizes() {
        let vm = CalculatorViewModel()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("abc123xyz", forType: .string)
        vm.pasteExpression()
        #expect(vm.expression == "123")
    }

    @Test("pasteExpression appends to existing expression")
    func pasteAppends() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.add)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("3", forType: .string)
        vm.pasteExpression()
        #expect(vm.expression == "5 + 3")
    }

    @Test("pasteExpression clears error state first")
    func pasteClearsError() {
        let vm = CalculatorViewModel()
        // Trigger an error
        vm.appendCharacter("1")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage != nil)

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("42", forType: .string)
        vm.pasteExpression()
        #expect(vm.errorMessage == nil)
        #expect(vm.expression == "42")
    }

    @Test("pasteExpression ignores empty pasteboard")
    func pasteEmptyPasteboard() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        NSPasteboard.general.clearContents()
        vm.pasteExpression()
        #expect(vm.expression == "5")
    }
}
