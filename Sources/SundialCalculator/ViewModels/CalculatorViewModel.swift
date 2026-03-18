import AVFoundation
import AppKit
import SwiftUI

@Observable
final class CalculatorViewModel {
    private static let accessibilityProfileDefaultsKey = "Sundial.AccessibilityProfile"
    private static let visualOnboardingDefaultsKey = "Sundial.VisualOnboardingSeen"
    private static let historyDefaultsKey = "Sundial.History"

    private let speechSynthesizer = AVSpeechSynthesizer()
    private let defaults: UserDefaults
    private let historyPersistenceEnabled: Bool
    private let historyLimit: Int

    init(
        defaults: UserDefaults = .standard,
        historyPersistenceEnabled: Bool = false,
        historyLimit: Int = 50
    ) {
        self.defaults = defaults
        self.historyPersistenceEnabled = historyPersistenceEnabled
        self.historyLimit = historyLimit
        loadAccessibilityProfile()
        loadVisualOnboardingState()
        loadHistory()
    }

    // MARK: - Display State

    var expression: String = ""
    var displayResult: String = ""
    var errorMessage: String?
    var lastResult: Double?

    // MARK: - History

    var history: [CalculationRecord] = [] {
        didSet { persistHistoryIfNeeded() }
    }

    // MARK: - Memory

    var memory: Double = 0
    var hasMemory: Bool = false

    // MARK: - Visual Answer

    var showVisualAnswer: Bool = true
    var selectedVisualType: VisualAnswerType = .numberLine
    var availableVisualTypes: [VisualAnswerType] = VisualAnswerType.allCases
    var autoVisualEnabled: Bool = true
    var inputMode: InputMode = .freeform
    var guidedHint: String?
    var recommendedVisual: VisualizationRecommendation?
    var explanation: CalculationExplanation?
    var confidenceCheck: ConfidenceCheck?
    var profile: AccessibilityProfile = AccessibilityProfile() {
        didSet { saveAccessibilityProfile() }
    }
    private var seenVisualOnboarding: Set<String> = []

    // MARK: - Replay State

    var trace: ComputationTrace?
    var currentStepIndex: Int = 0
    var isReplayPlaying: Bool = false

    // MARK: - Last Operation Context (for visual answers)

    var lastOperands: (left: Double, right: Double)?
    var lastOperator: Operator?
    private var lastRightOperandWasPercent: Bool = false
    private var lastRawRightOperand: Double?
    private var replayTimer: Timer?

    deinit {
        replayTimer?.invalidate()
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Derived Visualization Context

    var visualResult: Double? {
        if let step = activeReplayStep {
            return step.result
        }
        return lastResult
    }

    var visualOperands: (left: Double, right: Double)? {
        if let step = activeReplayStep {
            return (step.left, step.right)
        }
        return lastOperands
    }

    var visualOperator: Operator? {
        if let step = activeReplayStep {
            return step.op
        }
        return lastOperator
    }

    var canReplay: Bool {
        guard let trace else { return false }
        return !trace.steps.isEmpty
    }

    var replayStepDescription: String? {
        guard let trace, let step = activeReplayStep else { return nil }
        return "Step \(currentStepIndex + 1) of \(trace.steps.count): \(step.summary)"
    }

    var guidedTokenSlots: [String] {
        tokenizeGuidedExpression(expression)
    }

    var guidedNextSlotLabel: String {
        guard inputMode == .guided else { return "" }
        switch guidedExpectation {
        case .number:
            return "Next slot: number"
        case .operation:
            return "Next slot: operator or evaluate"
        }
    }

    var shouldShowVisualOnboarding: Bool {
        guard visualResult != nil else { return false }
        return !seenVisualOnboarding.contains(selectedVisualType.rawValue)
    }

    var visualOnboardingText: String {
        switch selectedVisualType {
        case .numberLine:
            return "Track direction first: right means larger, left means smaller."
        case .breakdown:
            return "Read the value as chunks: place values add up to the total."
        case .proportion:
            return "Use this for percents: compare part-to-whole before reading numbers."
        case .orderOfMagnitude:
            return "Use this to sanity-check scale for very large or very small values."
        case .areaGrid:
            return "Count groups/rows/columns to verify multiplication and division structure."
        }
    }

    // MARK: - Input

    func appendCharacter(_ char: String) {
        clearExpressionIfError()
        if inputMode == .guided, guidedShouldBlockDigitAppend() {
            guidedHint = "Choose an operator before starting another number."
            return
        }
        expression += char
        if inputMode == .guided {
            guidedHint = "Next: choose an operator or continue this number."
        }
    }

    func appendOperator(_ op: Operator) {
        clearExpressionIfError()
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            if let last = lastResult {
                expression = CalculatorEngine.formatResult(last)
            } else if op == .subtract {
                expression = "-"
                if inputMode == .guided {
                    guidedHint = "Enter a number after the negative sign."
                }
                return
            } else {
                if inputMode == .guided {
                    guidedHint = "Start with a number before adding an operator."
                }
                return
            }
        }

        if hasTrailingBinaryOperator(expression) {
            replaceTrailingBinaryOperator(with: op.rawValue)
            return
        }

        if let last = lastNonWhitespaceCharacter(in: expression), last == "(" || last == "√" {
            if op == .subtract {
                expression += "-"
            }
            if inputMode == .guided {
                guidedHint = "Enter the number for this term."
            }
            return
        }

        guard canAppendBinaryOperator(to: expression) else {
            if inputMode == .guided {
                guidedHint = "Add a number before the next operator."
            }
            return
        }
        expression += " \(op.rawValue) "
        if inputMode == .guided {
            guidedHint = "Now enter the next number."
        }
    }

    func appendParenthesis(_ paren: String) {
        clearExpressionIfError()
        if paren == "(" {
            // Add implicit multiply: 5( → 5 × (
            if let last = lastNonWhitespaceCharacter(in: expression), last.isNumber || last == ")" || last == "%" {
                expression += " × "
            }
            expression += "("
        } else {
            if inputMode == .guided {
                guard canCloseParenthesis(in: expression) else {
                    guidedHint = "Add a number before closing the parenthesis."
                    return
                }
            }
            expression += ")"
        }
        if inputMode == .guided {
            guidedHint = guidedNextSlotLabel
        }
    }

    func appendPercent() {
        clearExpressionIfError()
        if inputMode == .guided, !canAppendPercent(to: expression) {
            guidedHint = "Percent must follow a number."
            return
        }
        expression += "%"
        if inputMode == .guided {
            guidedHint = "Percent applied. Evaluate or add another operator."
        }
    }

    func appendPower() {
        clearExpressionIfError()
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            guard let last = lastResult else { return }
            expression = CalculatorEngine.formatResult(last)
        }

        if hasTrailingBinaryOperator(expression) {
            replaceTrailingBinaryOperator(with: Operator.power.rawValue)
            return
        }

        guard canAppendBinaryOperator(to: expression) else {
            if inputMode == .guided {
                guidedHint = "Power needs a base value first."
            }
            return
        }
        expression += " ^ "
        if inputMode == .guided {
            guidedHint = "Enter the exponent value."
        }
    }

    func appendSquareRoot() {
        clearExpressionIfError()
        if inputMode == .guided,
           let last = lastNonWhitespaceCharacter(in: expression),
           (last.isNumber || last == ")" || last == "%") {
            expression += " × "
        }
        expression += "√"
        if inputMode == .guided {
            guidedHint = "Enter the value inside the square root."
        }
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
            if inputMode == .guided {
                guidedHint = "This number already contains a decimal point."
            }
            return
        }
        if expression.isEmpty || " +−×÷(".contains(expression.last!) {
            expression += "0."
        } else {
            expression += "."
        }
        if inputMode == .guided {
            guidedHint = "Continue entering digits."
        }
    }

    // MARK: - Actions

    func evaluate() {
        guard !expression.isEmpty else { return }
        do {
            stopReplay()
            let generatedTrace = try CalculatorEngine.evaluateWithTrace(expression)
            trace = generatedTrace
            if generatedTrace.steps.isEmpty {
                currentStepIndex = 0
            } else {
                currentStepIndex = generatedTrace.steps.count - 1
            }

            let result = generatedTrace.finalResult
            let record = CalculationRecord(expression: expression, result: result)
            history.insert(record, at: 0)

            // Extract operands for visual answers
            extractOperands(from: expression, result: result)
            updateFeedback(forExpression: expression, result: result)
            updateConfidenceCheck(result: result)
            speakMeaningCheckIfNeeded()

            if history.count > historyLimit {
                history.removeLast(history.count - historyLimit)
            }

            displayResult = record.formattedResult
            lastResult = result
            errorMessage = nil
            expression = ""
        } catch let error as CalculatorEngine.EngineError {
            switch error {
            case .divisionByZero:
                errorMessage = "Cannot divide by zero"
            case .invalidExpression:
                errorMessage = inputMode == .guided
                    ? "Incomplete guided expression. Add a number after the operator."
                    : "Invalid expression"
            case .mismatchedParentheses:
                errorMessage = inputMode == .guided
                    ? "Close each opening parenthesis before evaluating."
                    : "Mismatched parentheses"
            case .emptyExpression:
                errorMessage = "Enter an expression"
            case .undefinedResult:
                errorMessage = "Undefined result"
            }
            recommendedVisual = nil
            explanation = nil
            confidenceCheck = nil
            resetReplayState()
        } catch {
            errorMessage = "Error"
            recommendedVisual = nil
            explanation = nil
            confidenceCheck = nil
            resetReplayState()
        }
    }

    func clear() {
        stopReplay()
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        expression = ""
        displayResult = ""
        errorMessage = nil
        lastResult = nil
        lastOperands = nil
        lastOperator = nil
        recommendedVisual = nil
        explanation = nil
        confidenceCheck = nil
        guidedHint = nil
        trace = nil
        currentStepIndex = 0
        lastRightOperandWasPercent = false
        lastRawRightOperand = nil
        availableVisualTypes = VisualAnswerType.allCases
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

    func setInputMode(_ mode: InputMode) {
        inputMode = mode
        if mode == .guided {
            guidedHint = expression.isEmpty ? "Guided mode: number -> operator -> number." : guidedNextSlotLabel
        } else {
            guidedHint = nil
        }
    }

    func setSlowerAnimationsEnabled(_ enabled: Bool) {
        profile.slowerAnimations = enabled
    }

    func setLargeTextEnabled(_ enabled: Bool) {
        profile.largeText = enabled
    }

    func setSimplifiedNotationEnabled(_ enabled: Bool) {
        profile.simplifiedNotation = enabled
    }

    func setSpokenMeaningChecksEnabled(_ enabled: Bool) {
        profile.spokenMeaningChecks = enabled
        if !enabled, speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    func setReducedVisualComplexityEnabled(_ enabled: Bool) {
        profile.reducedVisualComplexity = enabled
    }

    func markVisualOnboardingSeen() {
        seenVisualOnboarding.insert(selectedVisualType.rawValue)
        saveVisualOnboardingState()
    }

    func resetVisualOnboarding() {
        seenVisualOnboarding.removeAll()
        saveVisualOnboardingState()
    }

    func replayPrevious() {
        guard canReplay else { return }
        stopReplay()
        currentStepIndex = max(currentStepIndex - 1, 0)
    }

    func replayNext() {
        guard let trace, !trace.steps.isEmpty else { return }
        stopReplay()
        currentStepIndex = min(currentStepIndex + 1, trace.steps.count - 1)
    }

    func replayReset() {
        guard canReplay else { return }
        stopReplay()
        currentStepIndex = 0
    }

    func toggleReplay() {
        if isReplayPlaying {
            stopReplay()
        } else {
            startReplay()
        }
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
        guard hasMemory else { return }
        clearExpressionIfError()

        let recallText = CalculatorEngine.formatResult(memory)
        guard !expression.isEmpty else {
            expression = recallText
            return
        }

        if let last = lastNonWhitespaceCharacter(in: expression), last.isNumber || last == ")" || last == "%" {
            expression += " × \(recallText)"
        } else {
            expression += recallText
        }
    }

    func memoryClear() {
        memory = 0
        hasMemory = false
    }

    // MARK: - History

    func recallFromHistory(_ record: CalculationRecord) {
        stopReplay()
        expression = record.expression
        displayResult = record.formattedResult
        lastResult = record.result
        extractOperands(from: record.expression, result: record.result)
        updateFeedback(forExpression: record.expression, result: record.result)
        updateConfidenceCheck(result: record.result)
        do {
            let regeneratedTrace = try CalculatorEngine.evaluateWithTrace(record.expression)
            trace = regeneratedTrace
            currentStepIndex = max(regeneratedTrace.steps.count - 1, 0)
        } catch {
            trace = nil
            currentStepIndex = 0
        }
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
        let normalized = text
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
        let allowed = CharacterSet(charactersIn: "0123456789.+-−*/×÷^%()√ ")
        let sanitized = String(normalized.unicodeScalars.filter { allowed.contains($0) })
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

    private func lastNonWhitespaceCharacter(in text: String) -> Character? {
        text.trimmingCharacters(in: .whitespaces).last
    }

    private func hasTrailingBinaryOperator(_ text: String) -> Bool {
        guard let last = lastNonWhitespaceCharacter(in: text) else { return false }
        return "+-−×÷*/^".contains(last)
    }

    private func replaceTrailingBinaryOperator(with symbol: String) {
        var trimmed = expression.trimmingCharacters(in: .whitespaces)
        guard let last = trimmed.last, "+-−×÷*/^".contains(last) else { return }

        trimmed.removeLast()
        expression = trimmed.trimmingCharacters(in: .whitespaces) + " \(symbol) "
    }

    private func canAppendBinaryOperator(to text: String) -> Bool {
        guard let last = lastNonWhitespaceCharacter(in: text) else { return false }
        return last.isNumber || last == "." || last == ")" || last == "%"
    }

    private func canAppendPercent(to text: String) -> Bool {
        guard let last = lastNonWhitespaceCharacter(in: text) else { return false }
        return last.isNumber || last == ")"
    }

    private func canCloseParenthesis(in text: String) -> Bool {
        let opens = text.filter { $0 == "(" }.count
        let closes = text.filter { $0 == ")" }.count
        guard opens > closes else { return false }
        guard let last = lastNonWhitespaceCharacter(in: text) else { return false }
        return last.isNumber || last == ")" || last == "%"
    }

    private func guidedShouldBlockDigitAppend() -> Bool {
        guard let last = lastNonWhitespaceCharacter(in: expression) else { return false }
        return last == ")" || last == "%"
    }

    private var guidedExpectation: GuidedExpectation {
        guard let last = lastNonWhitespaceCharacter(in: expression) else { return .number }
        if last.isNumber || last == "." || last == ")" || last == "%" {
            return .operation
        }
        return .number
    }

    private var activeReplayStep: ComputationStep? {
        guard let trace, !trace.steps.isEmpty else { return nil }
        let clamped = min(max(currentStepIndex, 0), trace.steps.count - 1)
        return trace.steps[clamped]
    }

    private func startReplay() {
        guard let trace, !trace.steps.isEmpty else { return }
        stopReplay()
        if currentStepIndex >= trace.steps.count - 1 {
            currentStepIndex = 0
        }

        isReplayPlaying = true
        let interval = profile.slowerAnimations ? 1.05 : 0.70
        replayTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard let trace = self.trace else {
                self.stopReplay()
                return
            }
            if self.currentStepIndex < trace.steps.count - 1 {
                self.currentStepIndex += 1
            } else {
                self.stopReplay()
            }
        }
    }

    private func stopReplay() {
        replayTimer?.invalidate()
        replayTimer = nil
        isReplayPlaying = false
    }

    private func resetReplayState() {
        stopReplay()
        trace = nil
        currentStepIndex = 0
    }

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
                lastRightOperandWasPercent = isPercent
                lastRawRightOperand = rawRight
                return
            }
        }
        // For complex expressions, just store the result
        lastOperands = nil
        lastOperator = nil
        lastRightOperandWasPercent = false
        lastRawRightOperand = nil
    }

    private func updateFeedback(forExpression expr: String, result: Double) {
        let recommendation = recommendVisualization(forExpression: expr, result: result)
        recommendedVisual = recommendation
        let available = availableVisualTypes(forExpression: expr, result: result)
        availableVisualTypes = available
        if autoVisualEnabled {
            selectedVisualType = recommendation.type
        } else if !available.contains(selectedVisualType) {
            selectedVisualType = available.first ?? recommendation.type
        }
        explanation = CalculationExplanation(text: buildExplanation(forExpression: expr, result: result))
    }

    private func recommendVisualization(forExpression expr: String, result: Double) -> VisualizationRecommendation {
        if expr.contains("%"), let op = lastOperator, op == .add || op == .subtract {
            return VisualizationRecommendation(
                type: .proportion,
                reason: "Percent changes are easiest to verify as part-to-whole bars."
            )
        }

        if let op = lastOperator {
            switch op {
            case .add, .subtract:
                return VisualizationRecommendation(
                    type: .numberLine,
                    reason: "Add/subtract is easiest to verify with directional movement."
                )
            case .multiply, .divide:
                let maxOperand = max(abs(lastOperands?.left ?? 0), abs(lastOperands?.right ?? 0))
                if maxOperand <= 12 {
                    return VisualizationRecommendation(
                        type: .areaGrid,
                        reason: "Groups and area make multiplicative structure concrete."
                    )
                }
                if abs(result) >= 1_000_000 || (abs(result) > 0 && abs(result) < 0.01) {
                    return VisualizationRecommendation(
                        type: .orderOfMagnitude,
                        reason: "Magnitude scale helps sanity-check large multiplicative jumps."
                    )
                }
                return VisualizationRecommendation(
                    type: .proportion,
                    reason: "Bar comparison makes multiplicative change easier to compare."
                )
            case .power:
                return VisualizationRecommendation(
                    type: .areaGrid,
                    reason: "Area is the clearest way to verify repeated multiplication."
                )
            }
        }

        if expr.contains("√") {
            return VisualizationRecommendation(
                type: .breakdown,
                reason: "Place-value decomposition helps verify root results."
            )
        }

        let absResult = abs(result)
        if absResult >= 1_000_000 || (absResult > 0 && absResult < 0.01) {
            return VisualizationRecommendation(
                type: .orderOfMagnitude,
                reason: "Magnitude scale helps sanity-check very large or very small values."
            )
        }
        if absResult >= 10 {
            return VisualizationRecommendation(
                type: .breakdown,
                reason: "Place-value view helps confirm multi-digit structure."
            )
        }

        return VisualizationRecommendation(
            type: .numberLine,
            reason: "Number-line placement helps verify small values."
        )
    }

    private func availableVisualTypes(forExpression expr: String, result: Double) -> [VisualAnswerType] {
        if expr.contains("%"), let op = lastOperator, op == .add || op == .subtract {
            return [.proportion, .numberLine, .breakdown]
        }

        if let op = lastOperator {
            switch op {
            case .add, .subtract:
                return [.numberLine, .breakdown, .proportion]
            case .multiply, .divide:
                if abs(result) >= 1_000_000 || (abs(result) > 0 && abs(result) < 0.01) {
                    return [.orderOfMagnitude, .proportion, .areaGrid]
                }
                return [.areaGrid, .proportion, .orderOfMagnitude]
            case .power:
                return [.areaGrid, .orderOfMagnitude, .breakdown]
            }
        }

        if expr.contains("√") {
            return [.breakdown, .numberLine, .orderOfMagnitude]
        }

        let absResult = abs(result)
        if absResult >= 1_000_000 || (absResult > 0 && absResult < 0.01) {
            return [.orderOfMagnitude, .breakdown, .numberLine]
        }
        if absResult >= 10 {
            return [.breakdown, .numberLine, .proportion]
        }
        return [.numberLine, .proportion, .breakdown]
    }

    private func buildExplanation(forExpression expr: String, result: Double) -> String {
        let resultText = CalculatorEngine.formatResult(result)

        if let op = lastOperator, let ops = lastOperands {
            let leftText = CalculatorEngine.formatResult(ops.left)
            let rightText = CalculatorEngine.formatResult(ops.right)

            switch op {
            case .add:
                if lastRightOperandWasPercent, let rawPercent = lastRawRightOperand {
                    return "You added \(CalculatorEngine.formatResult(rawPercent))% of \(leftText) (\(rightText)), so the total is \(resultText)."
                }
                return "You started with \(leftText), added \(rightText), and got \(resultText)."
            case .subtract:
                if lastRightOperandWasPercent, let rawPercent = lastRawRightOperand {
                    return "You subtracted \(CalculatorEngine.formatResult(rawPercent))% of \(leftText) (\(rightText)), so the result is \(resultText)."
                }
                return "You started with \(leftText), took away \(rightText), and got \(resultText)."
            case .multiply:
                if lastRightOperandWasPercent, let rawPercent = lastRawRightOperand {
                    return "You multiplied \(leftText) by \(CalculatorEngine.formatResult(rawPercent))% (\(rightText)), giving \(resultText)."
                }
                return "You made \(leftText) groups of \(rightText), giving \(resultText)."
            case .divide:
                return "You divided \(leftText) by \(rightText), giving \(resultText)."
            case .power:
                return "You raised \(leftText) to the power of \(rightText), giving \(resultText)."
            }
        }

        if expr.contains("√") {
            return "You took a square root and got \(resultText)."
        }

        if expr.contains("%") {
            return "This percentage expression evaluates to \(resultText)."
        }

        return "This expression evaluates to \(resultText). Use the visual check to confirm size and structure."
    }

    private func updateConfidenceCheck(result: Double) {
        let signDescriptor: String
        if result > 0 {
            signDescriptor = "positive"
        } else if result < 0 {
            signDescriptor = "negative"
        } else {
            signDescriptor = "zero"
        }

        if let op = lastOperator, let operands = lastOperands {
            let estimate = roughEstimate(op: op, left: operands.left, right: operands.right)
            let tolerance = max(abs(estimate) * 0.25, 1)
            let withinEstimate = abs(result - estimate) <= tolerance

            let estimateText = "Estimate ≈ \(CalculatorEngine.formatResult(estimate)); actual \(CalculatorEngine.formatResult(result))."
            let directionDescriptor: String
            if result > operands.left {
                directionDescriptor = "larger"
            } else if result < operands.left {
                directionDescriptor = "smaller"
            } else {
                directionDescriptor = "equal"
            }

            let directionText = "Direction check: result is \(directionDescriptor) than the starting value."
            let signText = "Sign check: result is \(signDescriptor)."
            confidenceCheck = ConfidenceCheck(
                estimateText: estimateText,
                directionText: directionText,
                signText: signText,
                withinEstimate: withinEstimate
            )
            return
        }

        // Fallback for complex expressions where left/right operands are not available.
        let roundedAnchor = result.rounded()
        let tolerance = max(abs(roundedAnchor) * 0.35, 1)
        let withinEstimate = abs(result - roundedAnchor) <= tolerance
        let estimateText = "Rounded check: \(CalculatorEngine.formatResult(roundedAnchor)); actual \(CalculatorEngine.formatResult(result))."
        let directionText = "Direction check: compare this result against your expected trend."
        let signText = "Sign check: result is \(signDescriptor)."
        confidenceCheck = ConfidenceCheck(
            estimateText: estimateText,
            directionText: directionText,
            signText: signText,
            withinEstimate: withinEstimate
        )
    }

    private func roughEstimate(op: Operator, left: Double, right: Double) -> Double {
        let leftRounded = left.rounded()
        let rightRounded = right.rounded()

        switch op {
        case .add:
            return leftRounded + rightRounded
        case .subtract:
            return leftRounded - rightRounded
        case .multiply:
            return leftRounded * rightRounded
        case .divide:
            if rightRounded == 0 {
                return leftRounded
            }
            return leftRounded / rightRounded
        case .power:
            if rightRounded == 0 { return 1 }
            if abs(rightRounded) > 8 { return pow(leftRounded, 2) }
            return pow(leftRounded, rightRounded)
        }
    }

    private func speakMeaningCheckIfNeeded() {
        guard profile.spokenMeaningChecks, let explanation else { return }
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: explanation.text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        speechSynthesizer.speak(utterance)
    }

    private func loadAccessibilityProfile() {
        guard let data = defaults.data(forKey: Self.accessibilityProfileDefaultsKey),
              let decoded = try? JSONDecoder().decode(AccessibilityProfile.self, from: data) else {
            return
        }
        profile = decoded
    }

    private func saveAccessibilityProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            defaults.set(encoded, forKey: Self.accessibilityProfileDefaultsKey)
        }
    }

    private func loadVisualOnboardingState() {
        let raw = defaults.stringArray(forKey: Self.visualOnboardingDefaultsKey) ?? []
        seenVisualOnboarding = Set(raw)
    }

    private func saveVisualOnboardingState() {
        defaults.set(Array(seenVisualOnboarding), forKey: Self.visualOnboardingDefaultsKey)
    }

    private func loadHistory() {
        guard historyPersistenceEnabled,
              let data = defaults.data(forKey: Self.historyDefaultsKey),
              let decoded = try? JSONDecoder().decode([CalculationRecord].self, from: data) else {
            return
        }
        history = Array(decoded.prefix(historyLimit))
    }

    private func persistHistoryIfNeeded() {
        guard historyPersistenceEnabled else { return }
        if history.isEmpty {
            defaults.removeObject(forKey: Self.historyDefaultsKey)
            return
        }
        let trimmed = Array(history.prefix(historyLimit))
        guard let encoded = try? JSONEncoder().encode(trimmed) else { return }
        defaults.set(encoded, forKey: Self.historyDefaultsKey)
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

    private func tokenizeGuidedExpression(_ text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }

        var tokens: [String] = []
        var currentNumber = ""
        let operators: Set<Character> = ["+", "−", "×", "÷", "^", "%", "(", ")", "√"]
        let scalarView = Array(trimmed)

        for index in scalarView.indices {
            let char = scalarView[index]
            if char.isWhitespace {
                if !currentNumber.isEmpty {
                    tokens.append(currentNumber)
                    currentNumber = ""
                }
                continue
            }

            if char.isNumber || char == "." {
                currentNumber.append(char)
                continue
            }

            if char == "-" {
                let previous = index > 0 ? scalarView[index - 1] : nil
                let unary = previous == nil || previous == "(" || operators.contains(previous!) || previous!.isWhitespace
                if unary {
                    currentNumber.append(char)
                    continue
                }
            }

            if !currentNumber.isEmpty {
                tokens.append(currentNumber)
                currentNumber = ""
            }
            if operators.contains(char) || char == "-" {
                tokens.append(String(char))
            }
        }

        if !currentNumber.isEmpty {
            tokens.append(currentNumber)
        }

        return tokens
    }
}

// MARK: - Visual Answer Type

enum VisualAnswerType: String, CaseIterable {
    case numberLine = "Number Line"
    case breakdown = "Place Value"
    case proportion = "Proportion"
    case orderOfMagnitude = "Magnitude"
    case areaGrid = "Area"
}

enum InputMode: String, CaseIterable {
    case freeform = "Freeform"
    case guided = "Guided"
}

private enum GuidedExpectation {
    case number
    case operation
}
