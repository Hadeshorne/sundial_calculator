import Foundation

enum PlaceValuePhase: String, CaseIterable {
    case before = "Before"
    case regroup = "Regroup"
    case after = "After"
}

struct PlaceValuePart: Equatable, Identifiable {
    let id: String
    let label: String
    let contribution: Double
    let magnitude: Double
    let proportion: Double

    var valueText: String {
        CalculatorEngine.formatResult(contribution)
    }
}

enum PlaceValueModel {
    static func decompose(_ value: Double) -> [PlaceValuePart] {
        let absValue = abs(value)
        guard absValue > 0, absValue < 1e12 else { return [] }

        let sign: Double = value < 0 ? -1 : 1
        let roundedToHundredths = (absValue * 100).rounded() / 100
        let integerPart = Int(roundedToHundredths)
        let scaled = Int((roundedToHundredths * 100).rounded())
        let decimalDigits = scaled % 100
        let tenthsDigit = decimalDigits / 10
        let hundredthsDigit = decimalDigits % 10

        let integerPlaces: [(Int, String)] = [
            (1_000_000_000, "billions"),
            (1_000_000, "millions"),
            (1_000, "thousands"),
            (100, "hundreds"),
            (10, "tens"),
            (1, "ones")
        ]

        var parts: [PlaceValuePart] = []

        for (placeValue, label) in integerPlaces {
            let digit = (integerPart / placeValue) % 10
            let contribution = Double(digit * placeValue) * sign
            guard contribution != 0 else { continue }
            parts.append(
                PlaceValuePart(
                    id: label,
                    label: label,
                    contribution: contribution,
                    magnitude: Double(placeValue),
                    proportion: min(abs(contribution) / max(absValue, 0.0000001), 1)
                )
            )
        }

        if tenthsDigit > 0 {
            let contribution = (Double(tenthsDigit) / 10) * sign
            parts.append(
                PlaceValuePart(
                    id: "tenths",
                    label: "tenths",
                    contribution: contribution,
                    magnitude: 0.1,
                    proportion: min(abs(contribution) / max(absValue, 0.0000001), 1)
                )
            )
        }

        if hundredthsDigit > 0 {
            let contribution = (Double(hundredthsDigit) / 100) * sign
            parts.append(
                PlaceValuePart(
                    id: "hundredths",
                    label: "hundredths",
                    contribution: contribution,
                    magnitude: 0.01,
                    proportion: min(abs(contribution) / max(absValue, 0.0000001), 1)
                )
            )
        }

        if parts.isEmpty {
            return [
                PlaceValuePart(
                    id: "ones",
                    label: "ones",
                    contribution: value,
                    magnitude: 1,
                    proportion: 1
                )
            ]
        }

        return parts
    }
}
