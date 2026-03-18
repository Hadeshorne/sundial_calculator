import Foundation

struct ComputationStep: Equatable, Identifiable {
    let id: Int
    let left: Double
    let right: Double
    let op: Operator
    let result: Double

    var summary: String {
        let leftText = CalculatorEngine.formatResult(left)
        let rightText = CalculatorEngine.formatResult(right)
        let resultText = CalculatorEngine.formatResult(result)
        return "\(leftText) \(op.rawValue) \(rightText) = \(resultText)"
    }
}
