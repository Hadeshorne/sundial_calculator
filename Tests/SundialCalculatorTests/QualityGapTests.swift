import Testing
@testable import SundialCalculator

// =============================================================================
// QUALITY GAP TESTS
// Tests derived from interprocedural code analysis (arxiv 2603.01896v1).
// Each test targets a specific gap identified in the structured audit.
// =============================================================================

@Suite("QG1: NaN / Infinity — Domain Errors")
struct NaNInfinityTests {

    @Test("√(negative) throws undefinedResult")
    func sqrtNegative() throws {
        #expect(throws: CalculatorEngine.EngineError.undefinedResult) {
            try CalculatorEngine.evaluate("√-4")
        }
    }

    @Test("√(negative) via subtraction: √(3 − 10) throws undefinedResult")
    func sqrtNegativeExpr() throws {
        #expect(throws: CalculatorEngine.EngineError.undefinedResult) {
            try CalculatorEngine.evaluate("√(3 − 10)")
        }
    }

    @Test("Negative base with fractional exponent: (-2)^0.5 throws undefinedResult")
    func negBaseFracExp() throws {
        #expect(throws: CalculatorEngine.EngineError.undefinedResult) {
            try CalculatorEngine.evaluate("(-2) ^ 0.5")
        }
    }

    @Test("Very large power causing Infinity: 10^1000 throws undefinedResult")
    func overflowPower() throws {
        #expect(throws: CalculatorEngine.EngineError.undefinedResult) {
            try CalculatorEngine.evaluate("10 ^ 1000")
        }
    }

    @Test("formatResult handles NaN gracefully")
    func formatNaN() {
        #expect(CalculatorEngine.formatResult(Double.nan) == "Error")
    }

    @Test("formatResult handles Infinity gracefully")
    func formatInfinity() {
        #expect(CalculatorEngine.formatResult(Double.infinity) == "Overflow")
    }

    @Test("formatResult handles negative Infinity")
    func formatNegInfinity() {
        #expect(CalculatorEngine.formatResult(-Double.infinity) == "-Overflow")
    }

    @Test("0^0 returns 1 (IEEE 754 convention)")
    func zeroPowerZero() throws {
        let result = try CalculatorEngine.evaluate("0 ^ 0")
        #expect(result == 1)
    }
}

// =============================================================================

@Suite("QG2: Error Recovery — Operator After Error")
struct ErrorRecoveryOperatorTests {

    @Test("Operator after error clears broken expression and starts fresh from lastResult")
    func operatorAfterError() {
        let vm = CalculatorViewModel()
        // Get a successful result first
        for ch in "100" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("\r")
        #expect(vm.displayResult == "100")

        // Now trigger an error
        for ch in "5" { vm.handleKeyPress(String(ch)) }
        vm.handleKeyPress("/")
        vm.handleKeyPress("0")
        vm.handleKeyPress("\r")
        #expect(vm.errorMessage == "Cannot divide by zero")
        #expect(vm.expression == "5 ÷ 0") // broken expression still present

        // Press + operator — should clear error and start from lastResult (100)
        vm.handleKeyPress("+")
        #expect(vm.errorMessage == nil)
        #expect(vm.expression.contains("100"))
        #expect(!vm.expression.contains("5 ÷ 0"))
    }

    @Test("Percent after error clears broken expression")
    func percentAfterError() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage != nil)

        vm.appendPercent()
        #expect(vm.errorMessage == nil)
        #expect(vm.expression == "%")
    }

    @Test("Power after error clears broken expression")
    func powerAfterError() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage != nil)

        vm.appendPower()
        #expect(vm.errorMessage == nil)
        #expect(vm.expression == "")
    }

    @Test("Square root after error clears broken expression")
    func sqrtAfterError() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage != nil)

        vm.appendSquareRoot()
        #expect(vm.errorMessage == nil)
        #expect(vm.expression == "√")
    }

    @Test("Toggle sign after error clears broken expression")
    func toggleSignAfterError() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage != nil)

        vm.toggleSign()
        #expect(vm.errorMessage == nil)
    }

    @Test("√(negative) via ViewModel shows Undefined result error")
    func sqrtNegativeVM() {
        let vm = CalculatorViewModel()
        vm.appendSquareRoot()
        vm.appendParenthesis("(")
        vm.appendCharacter("3")
        vm.appendOperator(.subtract)
        vm.appendCharacter("1")
        vm.appendCharacter("0")
        vm.appendParenthesis(")")
        vm.evaluate()
        #expect(vm.errorMessage == "Undefined result")
        #expect(vm.history.count == 0)
    }
}

// =============================================================================

@Suite("QG3: Percent Operand Extraction for Visual Answers")
struct PercentOperandExtractionTests {

    @Test("200 + 10% extracts resolved right operand (20, not 10)")
    func addPercentOperand() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("2")
        vm.appendCharacter("0")
        vm.appendCharacter("0")
        vm.appendOperator(.add)
        vm.appendCharacter("1")
        vm.appendCharacter("0")
        vm.appendPercent()
        vm.evaluate()

        #expect(vm.displayResult == "220")
        #expect(vm.lastOperands?.left == 200)
        #expect(vm.lastOperands?.right == 20) // 10% of 200 = 20
        #expect(vm.lastOperator == .add)
    }

    @Test("1200 − 20% extracts resolved right operand (240, not 20)")
    func subtractPercentOperand() {
        let vm = CalculatorViewModel()
        for ch in "1200" { vm.appendCharacter(String(ch)) }
        vm.appendOperator(.subtract)
        for ch in "20" { vm.appendCharacter(String(ch)) }
        vm.appendPercent()
        vm.evaluate()

        #expect(vm.displayResult == "960")
        #expect(vm.lastOperands?.left == 1200)
        #expect(vm.lastOperands?.right == 240) // 20% of 1200 = 240
        #expect(vm.lastOperator == .subtract)
    }

    @Test("200 × 15% extracts right as decimal (0.15)")
    func multiplyPercentOperand() {
        let vm = CalculatorViewModel()
        for ch in "200" { vm.appendCharacter(String(ch)) }
        vm.appendOperator(.multiply)
        for ch in "15" { vm.appendCharacter(String(ch)) }
        vm.appendPercent()
        vm.evaluate()

        #expect(vm.displayResult == "30")
        #expect(vm.lastOperands?.left == 200)
        #expect(vm.lastOperands?.right == 0.15)
        #expect(vm.lastOperator == .multiply)
    }
}

// =============================================================================

@Suite("QG4: IEEE 754 Display Precision")
struct IEEE754PrecisionTests {

    @Test("0.1 + 0.2 displays as 0.3, not 0.30000000000000004")
    func classicFloatIssue() throws {
        let result = try CalculatorEngine.evaluate("0.1 + 0.2")
        let formatted = CalculatorEngine.formatResult(result)
        #expect(formatted == "0.3")
    }

    @Test("0.1 + 0.2 + 0.3 displays cleanly")
    func chainedFloatIssue() throws {
        let result = try CalculatorEngine.evaluate("0.1 + 0.2 + 0.3")
        let formatted = CalculatorEngine.formatResult(result)
        #expect(formatted == "0.6")
    }

    @Test("1.1 × 1.1 displays cleanly")
    func multiplyFloat() throws {
        let result = try CalculatorEngine.evaluate("1.1 × 1.1")
        let formatted = CalculatorEngine.formatResult(result)
        #expect(formatted == "1.21")
    }

    @Test("Large precise result maintains accuracy")
    func largePrecise() throws {
        let result = try CalculatorEngine.evaluate("123456789 + 1")
        let formatted = CalculatorEngine.formatResult(result)
        #expect(formatted == "123456790")
    }

    @Test("Very small decimals still use scientific notation")
    func tinyDecimal() {
        let formatted = CalculatorEngine.formatResult(0.000001)
        #expect(formatted == "1e-06")
    }
}

// =============================================================================

@Suite("QG5: Backspace Edge Cases")
struct BackspaceEdgeCaseTests {

    @Test("Backspace after √ removes the √")
    func backspaceSqrt() {
        let vm = CalculatorViewModel()
        vm.appendSquareRoot()
        #expect(vm.expression == "√")
        vm.backspace()
        #expect(vm.expression == "")
    }

    @Test("Backspace after ^ removes the spaced operator")
    func backspacePower() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendPower()
        #expect(vm.expression == "5 ^ ")
        vm.backspace()
        #expect(vm.expression == "5")
    }

    @Test("Backspace after % removes the %")
    func backspacePercent() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendCharacter("0")
        vm.appendPercent()
        #expect(vm.expression == "50%")
        vm.backspace()
        #expect(vm.expression == "50")
    }
}

// =============================================================================

@Suite("QG6: Chained Operations Robustness")
struct ChainedOperationsTests {

    @Test("Error then digit then operator builds valid expression")
    func errorDigitOperator() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("5")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage != nil)

        vm.appendCharacter("1")
        vm.appendCharacter("0")
        vm.appendOperator(.add)
        vm.appendCharacter("5")
        vm.evaluate()
        #expect(vm.displayResult == "15")
        #expect(vm.errorMessage == nil)
    }

    @Test("Multiple errors in sequence don't corrupt state")
    func multipleErrors() {
        let vm = CalculatorViewModel()
        // First error
        vm.appendCharacter("5")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage != nil)

        // Second error
        vm.appendCharacter("1")
        vm.appendCharacter("0")
        vm.appendOperator(.divide)
        vm.appendCharacter("0")
        vm.evaluate()
        #expect(vm.errorMessage != nil)

        // Recover
        vm.appendCharacter("4")
        vm.appendCharacter("2")
        vm.evaluate()
        #expect(vm.displayResult == "42")
        #expect(vm.errorMessage == nil)
    }
}
