import Foundation

struct VisualizationRecommendation: Equatable {
    let type: VisualAnswerType
    let reason: String
}

struct CalculationExplanation: Equatable {
    let text: String
}
