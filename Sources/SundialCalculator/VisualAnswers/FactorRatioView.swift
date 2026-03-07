import SwiftUI

struct FactorRatioView: View {
    let result: Double
    let operands: (left: Double, right: Double)?
    let op: Operator?

    var body: some View {
        if let ops = operands {
            comparisonDisplay(ops: ops)
        } else {
            singleValueDisplay()
        }
    }

    // MARK: - Two-operand comparison

    @ViewBuilder
    private func comparisonDisplay(ops: (left: Double, right: Double)) -> some View {
        let leftAbs = abs(ops.left)
        let rightAbs = abs(ops.right)
        let larger = max(leftAbs, rightAbs)
        let ratio = larger > 0 ? max(leftAbs, rightAbs) / max(min(leftAbs, rightAbs), 1e-15) : 1

        // For add/subtract with percentage context, show before/after with increment
        let isAddSub = (op == .add || op == .subtract)

        GeometryReader { geo in
            let barWidth = geo.size.width * 0.75

            VStack(alignment: .leading, spacing: 6) {
                // Top bar (left operand)
                HStack(spacing: 8) {
                    let leftFraction = larger > 0 ? leftAbs / larger : 0.5
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.blue.opacity(0.7))
                        .frame(width: max(4, barWidth * CGFloat(leftFraction)), height: 24)
                        .overlay(alignment: .leading) {
                            Text(CalculatorEngine.formatResult(ops.left))
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(.leading, 6)
                                .minimumScaleFactor(0.5)
                        }

                    if isAddSub {
                        Text(ops.left < 0 ? "" : "")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }

                // Bottom bar (right operand or result)
                HStack(spacing: 8) {
                    if isAddSub {
                        // Show result with the increment highlighted
                        let resultAbs = abs(result)
                        let resultFraction = larger > 0 ? min(resultAbs / larger, 1.5) : 0.5
                        let baseFraction = larger > 0 ? leftAbs / larger : 0.5

                        ZStack(alignment: .leading) {
                            // Full result bar
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.green.opacity(0.5))
                                .frame(width: max(4, barWidth * CGFloat(resultFraction)), height: 24)

                            // Base portion
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.blue.opacity(0.4))
                                .frame(width: max(4, barWidth * CGFloat(baseFraction)), height: 24)
                        }

                        Text("= \(CalculatorEngine.formatResult(result))")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(.green)
                    } else {
                        let rightFraction = larger > 0 ? rightAbs / larger : 0.5
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.orange.opacity(0.7))
                            .frame(width: max(4, barWidth * CGFloat(rightFraction)), height: 24)
                            .overlay(alignment: .leading) {
                                Text(CalculatorEngine.formatResult(ops.right))
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding(.leading, 6)
                                    .minimumScaleFactor(0.5)
                            }
                    }
                }

                // Ratio annotation
                HStack(spacing: 4) {
                    if isAddSub {
                        let change = result - ops.left
                        let pct = ops.left != 0 ? (change / ops.left) * 100 : 0
                        Text(op == .add ? "+" : "")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Text(CalculatorEngine.formatResult(abs(change)))
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.orange)
                        if ops.left != 0 {
                            Text("(\(String(format: "%+.1f", pct))%)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }
                    } else {
                        Text(ratioLabel(ratio, leftAbs: leftAbs, rightAbs: rightAbs))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Text("= \(CalculatorEngine.formatResult(result))")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(.green)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
        }
        .accessibilityElement()
        .accessibilityLabel(factorDescription())
    }

    // MARK: - Single value fallback

    @ViewBuilder
    private func singleValueDisplay() -> some View {
        let reference = nearestRoundNumber(result)
        let ratio = reference > 0 ? abs(result) / reference : 0

        GeometryReader { geo in
            let barWidth = geo.size.width * 0.75

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.green.opacity(0.7))
                        .frame(width: max(4, barWidth * CGFloat(min(ratio, 1.0))), height: 24)
                    Text(CalculatorEngine.formatResult(result))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                }

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.secondary.opacity(0.2))
                        .frame(width: barWidth, height: 24)
                    Text(CalculatorEngine.formatResult(reference))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Text("\(String(format: "%.1f", ratio * 100))% of \(CalculatorEngine.formatResult(reference))")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
        }
        .accessibilityElement()
        .accessibilityLabel(factorDescription())
    }

    // MARK: - Helpers

    private func ratioLabel(_ ratio: Double, leftAbs: Double, rightAbs: Double) -> String {
        if ratio < 100 {
            return String(format: "%.1f\u{00D7}", ratio)
        }
        return String(format: "%.0f\u{00D7}", ratio)
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

    private func factorDescription() -> String {
        if let ops = operands, let op = op {
            return "Factor comparison: \(CalculatorEngine.formatResult(ops.left)) \(op.rawValue) \(CalculatorEngine.formatResult(ops.right)) equals \(CalculatorEngine.formatResult(result))"
        }
        return "Factor view showing \(CalculatorEngine.formatResult(result))"
    }
}
