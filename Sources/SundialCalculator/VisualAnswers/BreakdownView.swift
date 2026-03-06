import SwiftUI

struct BreakdownView: View {
    let value: Double

    var body: some View {
        let parts = decompose(value)

        HStack(spacing: 12) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                VStack(spacing: 4) {
                    Text(part.label)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(colorForPlace(part.place))
                        .frame(
                            width: max(30, CGFloat(part.proportion) * 200),
                            height: 40
                        )
                        .overlay {
                            Text(part.valueStr)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.white)
                        }

                    if index < parts.count - 1 {
                        Text("+")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            if !parts.isEmpty {
                VStack(spacing: 4) {
                    Text("")
                        .font(.system(size: 10))
                    Text("=")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("")
                        .font(.system(size: 10))
                }

                VStack(spacing: 4) {
                    Text("Total")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.green.opacity(0.8))
                        .frame(width: 60, height: 40)
                        .overlay {
                            Text(CalculatorEngine.formatResult(value))
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .minimumScaleFactor(0.5)
                        }
                    Text("")
                        .font(.system(size: 10))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement()
        .accessibilityLabel(breakdownDescription())
    }

    private struct PlacePart {
        let label: String
        let valueStr: String
        let place: Int
        let proportion: Double
    }

    private func decompose(_ val: Double) -> [PlacePart] {
        let absVal = abs(val)
        guard absVal > 0, absVal < 1e12 else { return [] }

        let intPart = Int(absVal)
        guard intPart > 0 else {
            return [PlacePart(label: "ones", valueStr: CalculatorEngine.formatResult(val), place: 0, proportion: 1.0)]
        }

        var parts: [PlacePart] = []
        let places = [
            (1_000_000_000, "billions"),
            (1_000_000, "millions"),
            (1_000, "thousands"),
            (100, "hundreds"),
            (10, "tens"),
            (1, "ones"),
        ]

        for (placeValue, label) in places {
            let digit = (intPart / placeValue) % (placeValue >= 10 ? 10 : 10)
            let contribution = digit * placeValue
            if contribution > 0 {
                parts.append(PlacePart(
                    label: label,
                    valueStr: "\(contribution)",
                    place: placeValue,
                    proportion: Double(contribution) / absVal
                ))
            }
        }

        // Handle sign
        if val < 0 && !parts.isEmpty {
            parts[0] = PlacePart(
                label: parts[0].label,
                valueStr: "-\(parts[0].valueStr)",
                place: parts[0].place,
                proportion: parts[0].proportion
            )
        }

        return parts
    }

    private func colorForPlace(_ place: Int) -> Color {
        switch place {
        case 1_000_000_000: return .purple
        case 1_000_000: return .indigo
        case 1_000: return .blue
        case 100: return .teal
        case 10: return .orange
        case 1: return .red.opacity(0.8)
        default: return .gray
        }
    }

    private func breakdownDescription() -> String {
        let parts = decompose(value)
        if parts.isEmpty { return "Place value breakdown of \(CalculatorEngine.formatResult(value))" }
        let partDescs = parts.map { "\($0.valueStr) \($0.label)" }
        return "Place value: \(partDescs.joined(separator: " plus ")) equals \(CalculatorEngine.formatResult(value))"
    }
}
