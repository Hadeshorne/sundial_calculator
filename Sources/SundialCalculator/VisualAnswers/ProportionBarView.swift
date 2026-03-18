import SwiftUI

struct ProportionBarView: View {
    let result: Double
    let operands: (left: Double, right: Double)?
    let op: Operator?

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            if let ops = operands {
                // Show proportion between operands and result
                proportionDisplay(ops: ops, width: width, height: height)
            } else {
                // Single value: show as proportion of nearest round number
                singleValueDisplay(width: width, height: height)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(proportionDescription())
    }

    @ViewBuilder
    private func proportionDisplay(ops: (left: Double, right: Double), width: CGFloat, height: CGFloat) -> some View {
        let total = abs(result)
        let leftAbs = abs(ops.left)
        let rightAbs = abs(ops.right)

        VStack(alignment: .leading, spacing: 8) {
            if op == .add || op == .subtract {
                // Stacked bar showing composition
                HStack(spacing: 0) {
                    if total > 0 {
                        let leftFrac = min(leftAbs / total, 1.0)
                        let rightFrac = min(rightAbs / total, 1.0)

                        Rectangle()
                            .fill(.blue.opacity(0.7))
                            .frame(width: max(2, width * CGFloat(leftFrac) * 0.8))
                            .overlay {
                                Text(CalculatorEngine.formatResult(ops.left))
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .minimumScaleFactor(0.5)
                            }

                        Rectangle()
                            .fill(.orange.opacity(0.7))
                            .frame(width: max(2, width * CGFloat(rightFrac) * 0.8))
                            .overlay {
                                Text(CalculatorEngine.formatResult(ops.right))
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .minimumScaleFactor(0.5)
                            }
                    }
                }
                .frame(height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // Result bar
                Rectangle()
                    .fill(.green.opacity(0.6))
                    .frame(width: width * 0.8, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay {
                        Text("= \(CalculatorEngine.formatResult(result))")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
            } else {
                // For multiply/divide, show scaled comparison bars.
                factorDisplay(ops: ops, width: width)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func factorDisplay(ops: (left: Double, right: Double), width: CGFloat) -> some View {
        let leftAbs = abs(ops.left)
        let rightAbs = abs(ops.right)
        let larger = max(leftAbs, rightAbs, 1e-15)
        let ratio = max(leftAbs, rightAbs) / max(min(leftAbs, rightAbs), 1e-15)
        let barWidth = width * 0.78

        VStack(alignment: .leading, spacing: 8) {
            comparisonBar(
                value: ops.left,
                fraction: leftAbs / larger,
                color: .blue,
                width: barWidth
            )

            comparisonBar(
                value: ops.right,
                fraction: rightAbs / larger,
                color: .orange,
                width: barWidth
            )

            HStack(spacing: 8) {
                Text(ratioLabel(ratio))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text(op?.rawValue ?? "")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text("= \(CalculatorEngine.formatResult(result))")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func singleValueDisplay(width: CGFloat, height: CGFloat) -> some View {
        let reference = nearestRoundNumber(result)
        let fraction = reference > 0 ? abs(result) / reference : 0

        VStack(alignment: .leading, spacing: 6) {
            // Reference bar (full width)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: width * 0.85, height: 28)

                RoundedRectangle(cornerRadius: 6)
                    .fill(.blue.opacity(0.6))
                    .frame(width: max(4, width * 0.85 * CGFloat(min(fraction, 1.0))), height: 28)
            }

            HStack {
                Text("\(CalculatorEngine.formatResult(result))")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.blue)
                Text("of \(CalculatorEngine.formatResult(reference))")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)

                if fraction > 0 {
                    Text("(\(String(format: "%.1f", fraction * 100))%)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }

    private func nearestRoundNumber(_ value: Double) -> Double {
        let absVal = abs(value)
        if absVal == 0 { return 1 }
        let magnitude = pow(10, floor(log10(absVal)))
        let normalized = absVal / magnitude
        if normalized <= 1 { return magnitude }
        if normalized <= 2 { return 2 * magnitude }
        if normalized <= 5 { return 5 * magnitude }
        return 10 * magnitude
    }

    private func comparisonBar(value: Double, fraction: Double, color: Color, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(color.opacity(0.7))
            .frame(width: max(6, width * CGFloat(fraction)), height: 26)
            .overlay(alignment: .leading) {
                Text(CalculatorEngine.formatResult(value))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.leading, 8)
                    .minimumScaleFactor(0.5)
            }
    }

    private func ratioLabel(_ ratio: Double) -> String {
        if ratio < 100 {
            return String(format: "%.1fx", ratio)
        }
        return String(format: "%.0fx", ratio)
    }

    private func proportionDescription() -> String {
        if let ops = operands, let op = op {
            return "Proportion view: \(CalculatorEngine.formatResult(ops.left)) \(op.rawValue) \(CalculatorEngine.formatResult(ops.right)) equals \(CalculatorEngine.formatResult(result))"
        }
        return "Proportion view showing \(CalculatorEngine.formatResult(result))"
    }
}
