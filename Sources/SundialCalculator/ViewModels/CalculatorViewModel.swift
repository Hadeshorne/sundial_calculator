import SwiftUI

@Observable
final class CalculatorViewModel {

    // MARK: - Display State

    var expression: String = ""
    var displayResult: String = ""
    var errorMessage: String?
    var lastResult: Double?

    // MARK: - History

    var history: [CalculationRecord] = []

    // MARK: - Memory

    var memory: Double = 0
    var hasMemory: Bool = false

    // MARK: - Visual Answer

    var showVisualAnswer: Bool = true
    var selectedVisualType: VisualAnswerType = .numberLine

    // MARK: - Last Operation Context (for visual answers)

    var lastOperands: (left: Double, right: Double)?
    var lastOperator: Operator?

    // MARK: - Input

    func appendCharacter(_ char: String) {
        clearExpressionIfError()
        expression += char
    }

    func appendOperator(_ op: Operator) {
        clearExpressionIfError()
        // If expression is empty and we have a last result, start from it
        if expression.isEmpty, let last = lastResult {
            expression = CalculatorEngine.formatResult(last)
        }
        expression += " \(op.rawValue) "
    }

    func appendParenthesis(_ paren: String) {
        clearExpressionIfError()
        if paren == "(" {
            // Add implicit multiply: 5( → 5 × (
            if let last = expression.last, last.isNumber || last == ")" || last == "%" {
                expression += " × "
            }
            expression += "("
        } else {
            expression += ")"
        }
    }

    func appendPercent() {
        clearExpressionIfError()
        expression += "%"
    }

    func appendPower() {
        clearExpressionIfError()
        expression += " ^ "
    }

    func appendSquareRoot() {
        clearExpressionIfError()
        expression += "√"
    }

    func toggleSign() {
        clearExpressionIfError()
        if expression.isEmpty, let last = lastResult {
            expression = CalculatorEngine.formatResult(-last)
            lastResult = -last
            displayResult = CalculatorEngine.formatResult(-last)
            return
        }
        // Try to negate the last number in the expression
        if let negated = negateLastNumber(in: expression) {
            expression = negated
        }
    }

    func appendDecimal() {
        clearExpressionIfError()
        // Only add decimal if the current number doesn't already have one
        let parts = expression.split(whereSeparator: { " +−×÷()".contains($0) })
        if let lastPart = parts.last, lastPart.contains(".") {
            return
        }
        if expression.isEmpty || " +−×÷(".contains(expression.last!) {
            expression += "0."
        } else {
            expression += "."
        }
    }

    // MARK: - Actions

    func evaluate() {
        guard !expression.isEmpty else { return }
        do {
            let result = try CalculatorEngine.evaluate(expression)
            let record = CalculationRecord(expression: expression, result: result)
            history.insert(record, at: 0)

            // Extract operands for visual answers
            extractOperands(from: expression, result: result)

            displayResult = record.formattedResult
            lastResult = result
            errorMessage = nil
            expression = ""
        } catch let error as CalculatorEngine.EngineError {
            switch error {
            case .divisionByZero:
                errorMessage = "Cannot divide by zero"
            case .invalidExpression:
                errorMessage = "Invalid expression"
            case .mismatchedParentheses:
                errorMessage = "Mismatched parentheses"
            case .emptyExpression:
                errorMessage = "Enter an expression"
            case .undefinedResult:
                errorMessage = "Undefined result"
            }
        } catch {
            errorMessage = "Error"
        }
    }

    func clear() {
        expression = ""
        displayResult = ""
        errorMessage = nil
        lastResult = nil
        lastOperands = nil
        lastOperator = nil
    }

    func allClear() {
        clear()
        history.removeAll()
        memory = 0
        hasMemory = false
    }

    func backspace() {
        guard !expression.isEmpty else { return }
        errorMessage = nil
        // Remove trailing whitespace + operator + whitespace if present
        if expression.hasSuffix(" ") {
            let trimmed = expression.trimmingCharacters(in: .whitespaces)
            if let last = trimmed.last, "+-−×÷*/^".contains(last) {
                expression = String(trimmed.dropLast()).trimmingCharacters(in: .whitespaces)
                return
            }
        }
        expression.removeLast()
    }

    // MARK: - Memory Functions

    func memoryAdd() {
        if let result = lastResult {
            memory += result
            hasMemory = true
        }
    }

    func memorySubtract() {
        if let result = lastResult {
            memory -= result
            hasMemory = true
        }
    }

    func memoryRecall() {
        if hasMemory {
            expression += CalculatorEngine.formatResult(memory)
        }
    }

    func memoryClear() {
        memory = 0
        hasMemory = false
    }

    // MARK: - History

    func recallFromHistory(_ record: CalculationRecord) {
        expression = record.expression
        displayResult = record.formattedResult
        lastResult = record.result
        extractOperands(from: record.expression, result: record.result)
    }

    func clearHistory() {
        history.removeAll()
    }

    func copyResult() {
        let text = displayResult.isEmpty ? expression : displayResult
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    func copyExpression() {
        guard !expression.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(expression, forType: .string)
    }

    func pasteExpression() {
        guard let text = NSPasteboard.general.string(forType: .string) else { return }
        clearExpressionIfError()
        let allowed = CharacterSet(charactersIn: "0123456789.+-*/^%()√ ")
        let sanitized = String(text.unicodeScalars.filter { allowed.contains($0) })
        if !sanitized.isEmpty {
            expression += sanitized
        }
    }

    // MARK: - Keyboard Input

    func handleKeyPress(_ key: String) {
        switch key {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            appendCharacter(key)
        case ".":
            appendDecimal()
        case "+":
            appendOperator(.add)
        case "-":
            appendOperator(.subtract)
        case "*":
            appendOperator(.multiply)
        case "/":
            appendOperator(.divide)
        case "%":
            appendPercent()
        case "^":
            appendPower()
        case "(":
            appendParenthesis("(")
        case ")":
            appendParenthesis(")")
        case "\r", "=":
            evaluate()
        case "\u{7F}": // Delete key
            backspace()
        default:
            break
        }
    }

    // MARK: - Error Clearing

    /// When there's an active error, clear the broken expression so the user starts fresh.
    private func clearExpressionIfError() {
        if errorMessage != nil {
            expression = ""
            errorMessage = nil
        }
    }

    // MARK: - Private Helpers

    private func extractOperands(from expr: String, result: Double) {
        // Simple extraction for binary operations like "A op B"
        let operators: [(String, Operator)] = [
            (" + ", .add), (" − ", .subtract), (" × ", .multiply), (" ÷ ", .divide), (" ^ ", .power)
        ]
        for (symbol, op) in operators {
            let parts = expr.components(separatedBy: symbol)
            if parts.count == 2,
               let left = Double(parts[0].trimmingCharacters(in: .whitespaces)) {
                let rightStr = parts[1].trimmingCharacters(in: .whitespaces)
                let isPercent = rightStr.hasSuffix("%")
                let cleanRight = rightStr.replacingOccurrences(of: "%", with: "")
                guard let rawRight = Double(cleanRight) else { continue }

                let resolvedRight: Double
                if isPercent && (op == .add || op == .subtract) {
                    // "200 + 10%" means the actual addend is 200 × 10/100 = 20
                    resolvedRight = left * rawRight / 100
                } else if isPercent {
                    // "200 × 10%" means right operand is 0.1
                    resolvedRight = rawRight / 100
                } else {
                    resolvedRight = rawRight
                }

                lastOperands = (left, resolvedRight)
                lastOperator = op
                return
            }
        }
        // For complex expressions, just store the result
        lastOperands = nil
        lastOperator = nil
    }

    private func negateLastNumber(in expr: String) -> String? {
        var chars = Array(expr)
        var end = chars.count - 1

        // Skip trailing whitespace
        while end >= 0 && chars[end].isWhitespace { end -= 1 }
        guard end >= 0 else { return nil }

        // Find the start of the last number
        var start = end
        while start > 0 && (chars[start - 1].isNumber || chars[start - 1] == ".") {
            start -= 1
        }

        // Check if there's already a negative sign
        if start > 0 && chars[start - 1] == "-" {
            chars.remove(at: start - 1)
        } else {
            chars.insert("-", at: start)
        }

        return String(chars)
    }
}

// MARK: - Visual Answer Type

enum VisualAnswerType: String, CaseIterable {
    case numberLine = "Number Line"
    case breakdown = "Place Value"
    case proportion = "Proportion"
    case orderOfMagnitude = "Magnitude"
    case factorRatio = "Factor"
    case areaGrid = "Area"
}
