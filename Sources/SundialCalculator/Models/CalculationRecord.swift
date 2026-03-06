import Foundation

struct CalculationRecord: Identifiable, Equatable {
    let id: UUID
    let expression: String
    let result: Double
    let formattedResult: String
    let timestamp: Date

    init(expression: String, result: Double) {
        self.id = UUID()
        self.expression = expression
        self.result = result
        self.formattedResult = CalculatorEngine.formatResult(result)
        self.timestamp = Date()
    }
}
