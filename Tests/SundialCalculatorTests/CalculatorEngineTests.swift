import Testing
@testable import SundialCalculator

@Suite("CalculatorEngine")
struct CalculatorEngineTests {

    // MARK: - Basic Arithmetic

    @Test("Addition")
    func addition() throws {
        #expect(try CalculatorEngine.evaluate("2 + 3") == 5)
        #expect(try CalculatorEngine.evaluate("0 + 0") == 0)
        #expect(try CalculatorEngine.evaluate("100 + 200") == 300)
        #expect(try CalculatorEngine.evaluate("1.5 + 2.5") == 4.0)
    }

    @Test("Subtraction")
    func subtraction() throws {
        #expect(try CalculatorEngine.evaluate("5 − 3") == 2)
        #expect(try CalculatorEngine.evaluate("5 - 3") == 2)
        #expect(try CalculatorEngine.evaluate("3 − 5") == -2)
        #expect(try CalculatorEngine.evaluate("0 − 0") == 0)
    }

    @Test("Multiplication")
    func multiplication() throws {
        #expect(try CalculatorEngine.evaluate("4 × 5") == 20)
        #expect(try CalculatorEngine.evaluate("4 * 5") == 20)
        #expect(try CalculatorEngine.evaluate("0 × 100") == 0)
        #expect(try CalculatorEngine.evaluate("2.5 × 4") == 10)
    }

    @Test("Division")
    func division() throws {
        #expect(try CalculatorEngine.evaluate("10 ÷ 2") == 5)
        #expect(try CalculatorEngine.evaluate("10 / 2") == 5)
        #expect(try CalculatorEngine.evaluate("7 ÷ 2") == 3.5)
        #expect(try CalculatorEngine.evaluate("0 ÷ 5") == 0)
    }

    // MARK: - Order of Operations

    @Test("Operator precedence")
    func precedence() throws {
        #expect(try CalculatorEngine.evaluate("2 + 3 × 4") == 14)
        #expect(try CalculatorEngine.evaluate("2 × 3 + 4") == 10)
        #expect(try CalculatorEngine.evaluate("10 − 2 × 3") == 4)
        #expect(try CalculatorEngine.evaluate("10 ÷ 2 + 3") == 8)
    }

    @Test("Parentheses")
    func parentheses() throws {
        #expect(try CalculatorEngine.evaluate("(2 + 3) × 4") == 20)
        #expect(try CalculatorEngine.evaluate("2 × (3 + 4)") == 14)
        #expect(try CalculatorEngine.evaluate("(10 − 2) × (3 + 1)") == 32)
        #expect(try CalculatorEngine.evaluate("((2 + 3))") == 5)
    }

    // MARK: - Negative Numbers

    @Test("Unary minus")
    func unaryMinus() throws {
        #expect(try CalculatorEngine.evaluate("-5") == -5)
        #expect(try CalculatorEngine.evaluate("-5 + 3") == -2)
        #expect(try CalculatorEngine.evaluate("3 + -2") == 1)
    }

    // MARK: - Decimals

    @Test("Decimal arithmetic")
    func decimals() throws {
        #expect(try CalculatorEngine.evaluate("0.1 + 0.2") == 0.1 + 0.2)
        #expect(try CalculatorEngine.evaluate("3.14 × 2") == 6.28)
        #expect(try CalculatorEngine.evaluate("10.5 ÷ 3") == 3.5)
    }

    // MARK: - Percentage

    @Test("Standalone percent")
    func standalonePercent() throws {
        #expect(try CalculatorEngine.evaluate("50%") == 0.5)
        #expect(try CalculatorEngine.evaluate("100%") == 1.0)
        #expect(try CalculatorEngine.evaluate("25%") == 0.25)
    }

    @Test("Percent in context: A + B%")
    func percentInContext() throws {
        // 200 + 10% should be 200 + (200 × 10/100) = 220
        #expect(try CalculatorEngine.evaluate("200 + 10%") == 220)
        // 100 − 25% should be 100 − (100 × 25/100) = 75
        #expect(try CalculatorEngine.evaluate("100 − 25%") == 75)
    }

    // MARK: - Error Handling

    @Test("Division by zero")
    func divisionByZero() throws {
        #expect(throws: CalculatorEngine.EngineError.divisionByZero) {
            try CalculatorEngine.evaluate("5 ÷ 0")
        }
    }

    @Test("Empty expression")
    func emptyExpression() throws {
        #expect(throws: CalculatorEngine.EngineError.emptyExpression) {
            try CalculatorEngine.evaluate("")
        }
        #expect(throws: CalculatorEngine.EngineError.emptyExpression) {
            try CalculatorEngine.evaluate("   ")
        }
    }

    @Test("Mismatched parentheses")
    func mismatchedParens() throws {
        #expect(throws: CalculatorEngine.EngineError.mismatchedParentheses) {
            try CalculatorEngine.evaluate("(2 + 3")
        }
        #expect(throws: CalculatorEngine.EngineError.mismatchedParentheses) {
            try CalculatorEngine.evaluate("2 + 3)")
        }
    }

    @Test("Invalid expression")
    func invalidExpression() throws {
        #expect(throws: CalculatorEngine.EngineError.invalidExpression) {
            try CalculatorEngine.evaluate("abc")
        }
    }

    // MARK: - Tokenizer

    @Test("Tokenize basic expression")
    func tokenize() throws {
        let tokens = try CalculatorEngine.tokenize("2 + 3")
        #expect(tokens == [.number(2), .op(.add), .number(3)])
    }

    @Test("Tokenize with parentheses")
    func tokenizeParens() throws {
        let tokens = try CalculatorEngine.tokenize("(2 + 3) × 4")
        #expect(tokens == [.leftParen, .number(2), .op(.add), .number(3), .rightParen, .op(.multiply), .number(4)])
    }

    // MARK: - Formatting

    @Test("Format integer results")
    func formatIntegers() {
        #expect(CalculatorEngine.formatResult(42) == "42")
        #expect(CalculatorEngine.formatResult(0) == "0")
        #expect(CalculatorEngine.formatResult(-7) == "-7")
        #expect(CalculatorEngine.formatResult(1000000) == "1000000")
    }

    @Test("Format decimal results")
    func formatDecimals() {
        #expect(CalculatorEngine.formatResult(3.14) == "3.14")
        #expect(CalculatorEngine.formatResult(0.5) == "0.5")
    }

    // MARK: - Complex Expressions

    @Test("Complex expressions")
    func complex() throws {
        #expect(try CalculatorEngine.evaluate("(100 + 50) × 2 ÷ 3") == 100)
        #expect(try CalculatorEngine.evaluate("1 + 2 + 3 + 4 + 5") == 15)
        #expect(try CalculatorEngine.evaluate("10 × 10 × 10") == 1000)
    }

    // MARK: - Large Numbers

    @Test("Large number arithmetic")
    func largeNumbers() throws {
        #expect(try CalculatorEngine.evaluate("999999 + 1") == 1000000)
        #expect(try CalculatorEngine.evaluate("1000000 × 1000") == 1000000000)
    }
}
