import Foundation

struct ComputationTrace: Equatable {
    let expression: String
    let steps: [ComputationStep]
    let finalResult: Double

    var hasReplayableSteps: Bool {
        !steps.isEmpty
    }
}
