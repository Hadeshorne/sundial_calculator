import Foundation

// MARK: - Token

enum Token: Equatable {
    case number(Double)
    case op(Operator)
    case unaryOp(UnaryOperator)
    case leftParen
    case rightParen
    case percent
}

// MARK: - Operator

enum Operator: String, Equatable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    case power = "^"

    var precedence: Int {
        switch self {
        case .add, .subtract: return 1
        case .multiply, .divide: return 2
        case .power: return 3
        }
    }

    var isLeftAssociative: Bool {
        switch self {
        case .power: return false  // 2^3^2 = 2^(3^2)
        default: return true
        }
    }

    func apply(_ a: Double, _ b: Double) -> Double? {
        switch self {
        case .add: return a + b
        case .subtract: return a - b
        case .multiply: return a * b
        case .divide: return b == 0 ? nil : a / b
        case .power:
            let result = pow(a, b)
            guard result.isFinite else { return nil }
            return result
        }
    }
}

// MARK: - Unary Operator

enum UnaryOperator: String, Equatable {
    case squareRoot = "√"

    var precedence: Int { 4 } // Higher than all binary operators

    func apply(_ a: Double) -> Double? {
        switch self {
        case .squareRoot:
            guard a >= 0 else { return nil }
            return sqrt(a)
        }
    }
}

// MARK: - CalculatorEngine

struct CalculatorEngine {

    enum EngineError: Error, Equatable {
        case invalidExpression
        case divisionByZero
        case mismatchedParentheses
        case emptyExpression
        case undefinedResult
    }

    // MARK: - Tokenizer

    static func tokenize(_ input: String) throws -> [Token] {
        var tokens: [Token] = []
        let chars = Array(input)
        var i = 0

        while i < chars.count {
            let ch = chars[i]

            if ch.isWhitespace {
                i += 1
                continue
            }

            if ch.isNumber || ch == "." {
                var numStr = String(ch)
                i += 1
                while i < chars.count && (chars[i].isNumber || chars[i] == ".") {
                    numStr.append(chars[i])
                    i += 1
                }
                guard let value = Double(numStr) else {
                    throw EngineError.invalidExpression
                }
                tokens.append(.number(value))
                continue
            }

            switch ch {
            case "+":
                tokens.append(.op(.add))
            case "−", "-":
                // Handle unary minus: if at start, after operator, or after left paren
                let isUnary = tokens.isEmpty
                    || tokens.last == .leftParen
                    || { if case .op = tokens.last { return true } else { return false } }()
                    || { if case .unaryOp = tokens.last { return true } else { return false } }()

                if isUnary {
                    // Read the next number and negate it
                    i += 1
                    // Skip whitespace after unary minus
                    while i < chars.count && chars[i].isWhitespace { i += 1 }

                    if i < chars.count && chars[i] == "(" {
                        // Handle -(expr): insert -1 × (
                        tokens.append(.number(-1))
                        tokens.append(.op(.multiply))
                        continue
                    }

                    guard i < chars.count && (chars[i].isNumber || chars[i] == ".") else {
                        throw EngineError.invalidExpression
                    }
                    var numStr = String(chars[i])
                    i += 1
                    while i < chars.count && (chars[i].isNumber || chars[i] == ".") {
                        numStr.append(chars[i])
                        i += 1
                    }
                    guard let value = Double(numStr) else {
                        throw EngineError.invalidExpression
                    }
                    tokens.append(.number(-value))
                    continue
                } else {
                    tokens.append(.op(.subtract))
                }
            case "×", "*":
                tokens.append(.op(.multiply))
            case "÷", "/":
                tokens.append(.op(.divide))
            case "^":
                tokens.append(.op(.power))
            case "√":
                tokens.append(.unaryOp(.squareRoot))
                i += 1
                continue
            case "(":
                tokens.append(.leftParen)
            case ")":
                tokens.append(.rightParen)
            case "%":
                tokens.append(.percent)
            default:
                throw EngineError.invalidExpression
            }

            i += 1
        }

        return tokens
    }

    // MARK: - Shunting-Yard → Evaluate

    static func evaluate(_ input: String) throws -> Double {
        let trace = try evaluateWithTrace(input)
        return trace.finalResult
    }

    static func evaluateWithTrace(_ input: String) throws -> ComputationTrace {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw EngineError.emptyExpression }

        let tokens = try tokenize(trimmed)
        let resolvedTokens = try resolvePercents(tokens)
        let evaluated = try evaluateInfixTokens(resolvedTokens, includeTrace: true)
        return ComputationTrace(
            expression: trimmed,
            steps: evaluated.steps,
            finalResult: evaluated.result
        )
    }

    private static func evaluateInfixTokens(_ tokens: [Token], includeTrace: Bool) throws -> (result: Double, steps: [ComputationStep]) {
        // Shunting-yard (infix -> postfix)
        var output: [Token] = []
        var operatorStack: [Token] = []

        for token in tokens {
            switch token {
            case .number:
                output.append(token)
            case .op(let op):
                while let top = operatorStack.last {
                    if case .op(let topOp) = top,
                       (op.isLeftAssociative && op.precedence <= topOp.precedence)
                        || (!op.isLeftAssociative && op.precedence < topOp.precedence) {
                        output.append(operatorStack.removeLast())
                    } else if case .unaryOp(let topUn) = top,
                              op.precedence < topUn.precedence {
                        // Pop unary ops with higher precedence (e.g., √ before +)
                        output.append(operatorStack.removeLast())
                    } else {
                        break
                    }
                }
                operatorStack.append(token)
            case .unaryOp:
                // Unary operators always go on the stack (highest precedence, right-associative)
                operatorStack.append(token)
            case .leftParen:
                operatorStack.append(token)
            case .rightParen:
                while let top = operatorStack.last, top != .leftParen {
                    output.append(operatorStack.removeLast())
                }
                guard operatorStack.last == .leftParen else {
                    throw EngineError.mismatchedParentheses
                }
                operatorStack.removeLast()
                // If there's a unary op on top after removing paren, pop it too
                if let top = operatorStack.last, case .unaryOp = top {
                    output.append(operatorStack.removeLast())
                }
            case .percent:
                break // Already resolved
            }
        }

        while let top = operatorStack.popLast() {
            if top == .leftParen || top == .rightParen {
                throw EngineError.mismatchedParentheses
            }
            output.append(top)
        }

        // Evaluate postfix
        var evalStack: [Double] = []
        var steps: [ComputationStep] = []
        var stepID = 0

        for token in output {
            switch token {
            case .number(let value):
                evalStack.append(value)
            case .op(let op):
                guard evalStack.count >= 2 else {
                    throw EngineError.invalidExpression
                }
                let b = evalStack.removeLast()
                let a = evalStack.removeLast()
                guard let result = op.apply(a, b) else {
                    if op == .divide {
                        throw EngineError.divisionByZero
                    }
                    throw EngineError.undefinedResult
                }
                evalStack.append(result)
                if includeTrace {
                    steps.append(
                        ComputationStep(
                            id: stepID,
                            left: a,
                            right: b,
                            op: op,
                            result: result
                        )
                    )
                    stepID += 1
                }
            case .unaryOp(let op):
                guard !evalStack.isEmpty else {
                    throw EngineError.invalidExpression
                }
                let a = evalStack.removeLast()
                guard let result = op.apply(a) else {
                    throw EngineError.undefinedResult
                }
                evalStack.append(result)
            default:
                throw EngineError.invalidExpression
            }
        }

        guard evalStack.count == 1 else {
            throw EngineError.invalidExpression
        }

        return (result: evalStack[0], steps: steps)
    }

    // MARK: - Percent Resolution

    /// Converts sequences like `number %` into `number / 100`.
    /// Handles `A + B%` as `A + (A × B / 100)` where `A` is the full
    /// left-hand expression value before the add/subtract operator.
    private static func resolvePercents(_ tokens: [Token]) throws -> [Token] {
        var result: [Token] = []

        var i = 0
        while i < tokens.count {
            if i + 1 < tokens.count, case .number(let value) = tokens[i], tokens[i + 1] == .percent {
                if let opIndex = lastBinaryOperatorIndex(in: result),
                   case .op(let lastOp) = result[opIndex],
                   (lastOp == .add || lastOp == .subtract) {
                    // A + B% means A + (A × B / 100), where A can be compound.
                    let leftExprTokens = Array(result[..<opIndex])
                    let baseValue = try evaluateInfixTokens(leftExprTokens, includeTrace: false).result
                    result.append(.number(baseValue * value / 100))
                } else {
                    // Standalone N% = N / 100
                    result.append(.number(value / 100))
                }
                i += 2
            } else {
                result.append(tokens[i])
                i += 1
            }
        }

        return result
    }

    private static func lastBinaryOperatorIndex(in tokens: [Token]) -> Int? {
        for index in stride(from: tokens.count - 1, through: 0, by: -1) {
            if case .op = tokens[index] {
                return index
            }
        }
        return nil
    }

    // MARK: - Formatting

    static func formatResult(_ value: Double) -> String {
        guard value.isFinite else {
            return value.isNaN ? "Error" : (value > 0 ? "Overflow" : "-Overflow")
        }
        if value == value.rounded() && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        // %.10g rounds to 10 significant digits, eliminating IEEE 754 noise
        // (artifacts typically appear at digit 15-17, well past this cutoff)
        let formatted = String(format: "%.10g", value)
        return formatted
    }
}
