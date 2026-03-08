import SwiftUI

struct OrderOfMagnitudeView: View {
    let result: Double
    let operands: (left: Double, right: Double)?
    let op: Operator?

    var body: some View {
        GeometryReader { geo in
            let scale = computeScale()
            let lineY = geo.size.height * 0.65

            Canvas { context, size in
                let padding: CGFloat = 40
                let usableWidth = size.width - 2 * padding

                // Draw main axis
                var linePath = Path()
                linePath.move(to: CGPoint(x: padding, y: lineY))
                linePath.addLine(to: CGPoint(x: size.width - padding, y: lineY))
                context.stroke(linePath, with: .color(.secondary), lineWidth: 1.5)

                // Draw magnitude tick marks and labels
                let tickCount = scale.maxExp - scale.minExp
                guard tickCount > 0 else { return }

                for i in 0...tickCount {
                    let exp = scale.minExp + i
                    let x = padding + usableWidth * CGFloat(Double(i) / Double(tickCount))

                    // Tick mark
                    var tick = Path()
                    tick.move(to: CGPoint(x: x, y: lineY - 5))
                    tick.addLine(to: CGPoint(x: x, y: lineY + 5))
                    context.stroke(tick, with: .color(.secondary), lineWidth: 1)

                    // Label
                    let label = magnitudeLabel(exp)
                    let text = Text(label).font(.system(size: 10, design: .monospaced)).foregroundColor(.secondary)
                    context.draw(text, at: CGPoint(x: x, y: lineY + 18))
                }

                // Plot operand markers if available
                if let ops = operands {
                    let leftX = xPosition(for: ops.left, scale: scale, padding: padding, usableWidth: usableWidth)
                    let leftDot = Path(ellipseIn: CGRect(x: leftX - 4, y: lineY - 4, width: 8, height: 8))
                    context.fill(leftDot, with: .color(.blue))

                    let rightX = xPosition(for: ops.right, scale: scale, padding: padding, usableWidth: usableWidth)
                    let rightDot = Path(ellipseIn: CGRect(x: rightX - 4, y: lineY - 4, width: 8, height: 8))
                    context.fill(rightDot, with: .color(.orange))

                    // Labels for operands
                    let leftLabel = Text(formatValue(ops.left)).font(.system(size: 10, weight: .medium)).foregroundColor(.blue)
                    context.draw(leftLabel, at: CGPoint(x: leftX, y: lineY - 14))

                    let rightLabel = Text(formatValue(ops.right)).font(.system(size: 10, weight: .medium)).foregroundColor(.orange)
                    context.draw(rightLabel, at: CGPoint(x: rightX, y: lineY - 26))
                }

                // Result marker (larger, prominent)
                let resultX = xPosition(for: result, scale: scale, padding: padding, usableWidth: usableWidth)
                let resultDot = Path(ellipseIn: CGRect(x: resultX - 5, y: lineY - 5, width: 10, height: 10))
                context.fill(resultDot, with: .color(.green))

                let resultLabel = Text(formatValue(result)).font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                let labelY: CGFloat = (operands != nil) ? lineY - 38 : lineY - 14
                context.draw(resultLabel, at: CGPoint(x: resultX, y: labelY))
            }
        }
        .accessibilityElement()
        .accessibilityLabel(magnitudeDescription())
    }

    // MARK: - Scale computation

    private struct MagnitudeScale {
        let minExp: Int
        let maxExp: Int
    }

    private func computeScale() -> MagnitudeScale {
        var values: [Double] = [result]
        if let ops = operands {
            values.append(ops.left)
            values.append(ops.right)
        }

        let absValues = values.map { abs($0) }.filter { $0 > 0 }
        guard !absValues.isEmpty else {
            return MagnitudeScale(minExp: 0, maxExp: 3)
        }

        let exponents = absValues.map { Int(floor(log10($0))) }
        let minExp = max((exponents.min() ?? 0) - 1, -3)
        let maxExp = (exponents.max() ?? 0) + 1

        // Ensure at least 3 ticks
        if maxExp - minExp < 3 {
            return MagnitudeScale(minExp: minExp, maxExp: minExp + 3)
        }

        return MagnitudeScale(minExp: minExp, maxExp: maxExp)
    }

    private func xPosition(for value: Double, scale: MagnitudeScale, padding: CGFloat, usableWidth: CGFloat) -> CGFloat {
        let absVal = abs(value)
        guard absVal > 0 else {
            return padding // zero at left edge
        }
        let logVal = log10(absVal)
        let fraction = (logVal - Double(scale.minExp)) / Double(scale.maxExp - scale.minExp)
        let clamped = min(max(fraction, 0), 1)
        return padding + usableWidth * CGFloat(clamped)
    }

    // MARK: - Formatting

    private func magnitudeLabel(_ exponent: Int) -> String {
        switch exponent {
        case ...(-1): return "0.\(String(repeating: "0", count: abs(exponent) - 1))1"
        case 0: return "1"
        case 1: return "10"
        case 2: return "100"
        case 3: return "1K"
        case 4: return "10K"
        case 5: return "100K"
        case 6: return "1M"
        case 7: return "10M"
        case 8: return "100M"
        case 9: return "1B"
        case 10: return "10B"
        case 11: return "100B"
        case 12: return "1T"
        default: return "10^\(exponent)"
        }
    }

    private func formatValue(_ value: Double) -> String {
        CalculatorEngine.formatResult(value)
    }

    private func magnitudeDescription() -> String {
        if let ops = operands, let op = op {
            return "Magnitude scale showing \(formatValue(ops.left)) \(op.rawValue) \(formatValue(ops.right)) equals \(formatValue(result))"
        }
        return "Magnitude scale showing result \(formatValue(result))"
    }
}
