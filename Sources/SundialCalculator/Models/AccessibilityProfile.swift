import Foundation

struct AccessibilityProfile: Codable, Equatable {
    var slowerAnimations: Bool = true
    var largeText: Bool = false
    var simplifiedNotation: Bool = false
    var spokenMeaningChecks: Bool = false
    var reducedVisualComplexity: Bool = false
}
