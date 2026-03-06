import SwiftUI

struct NumberLineView: View {
    let result: Double
    let operands: (left: Double, right: Double)?
    let op: Operator?

    var body: some View {
        GeometryReader { geo in
            let range = computeRange()
            let lineY = geo.size.height * 0.6

            Canvas { context, size in
                let padding: CGFloat = 40

                // Draw main line
                let lineStart = CGPoint(x: padding, y: lineY)
                let lineEnd = CGPoint(x: size.width - padding, y: lineY)

                var linePath = Path()
                linePath.move(to: lineStart)
                linePath.addLine(to: lineEnd)
                context.stroke(linePath, with: .color(.secondary), lineWidth: 1.5)

                // Draw tick marks and labels
                let usableWidth = size.width - 2 * padding
                let tickCount = min(10, max(3, Int(range.max - range.min) + 1))
                let step = (range.max - range.min) / Double(tickCount)

                for i in 0...tickCount {
                    let value = range.min + step * Double(i)
                    let x = padding + usableWidth * CGFloat(Double(i) / Double(tickCount))

                    // Tick
                    var tickPath = Path()
                    tickPath.move(to: CGPoint(x: x, y: lineY - 4))
                    tickPath.addLine(to: CGPoint(x: x, y: lineY + 4))
                    context.stroke(tickPath, with: .color(.secondary), lineWidth: 1)

                    // Label
                    let label = formatTick(value)
                    let text = Text(label).font(.system(size: 10, design: .monospaced)).foregroundColor(.secondary)
                    context.draw(text, at: CGPoint(x: x, y: lineY + 16))
                }

                // Draw operand markers if available
                if let ops = operands, let op = op {
                    let leftX = padding + usableWidth * CGFloat((ops.left - range.min) / (range.max - range.min))
                    let resultX = padding + usableWidth * CGFloat((result - range.min) / (range.max - range.min))

                    // Left operand dot
                    let leftDot = Path(ellipseIn: CGRect(x: leftX - 4, y: lineY - 4, width: 8, height: 8))
                    context.fill(leftDot, with: .color(.blue))

                    // Arrow from left to result
                    let arrowY = lineY - 20
                    var arrow = Path()
                    arrow.move(to: CGPoint(x: leftX, y: lineY - 5))
                    arrow.addLine(to: CGPoint(x: leftX, y: arrowY))
                    arrow.addLine(to: CGPoint(x: resultX, y: arrowY))
                    arrow.addLine(to: CGPoint(x: resultX, y: lineY - 5))
                    context.stroke(arrow, with: .color(.orange), lineWidth: 1.5)

                    // Jump label
                    let jumpLabel = "\(op.rawValue)\(formatTick(ops.right))"
                    let jumpText = Text(jumpLabel).font(.system(size: 11, weight: .medium)).foregroundColor(.orange)
                    context.draw(jumpText, at: CGPoint(x: (leftX + resultX) / 2, y: arrowY - 10))
                }

                // Result marker
                let resultX = padding + usableWidth * CGFloat((result - range.min) / (range.max - range.min))
                let resultDot = Path(ellipseIn: CGRect(x: resultX - 5, y: lineY - 5, width: 10, height: 10))
                context.fill(resultDot, with: .color(.green))

                // Result label
                let resultLabel = Text(formatTick(result)).font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                context.draw(resultLabel, at: CGPoint(x: resultX, y: lineY - 14))
            }
        }
        .accessibilityElement()
        .accessibilityLabel(numberLineDescription())
    }

    private func computeRange() -> (min: Double, max: Double) {
        var values: [Double] = [result]
        if let ops = operands {
            values.append(ops.left)
            values.append(ops.right)
        }

        let minVal = values.min()!
        let maxVal = values.max()!
        let span = max(abs(maxVal - minVal), 1)
        let padding = span * 0.2

        return (min: min(0, minVal - padding), max: maxVal + padding)
    }

    private func formatTick(_ value: Double) -> String {
        if value == value.rounded() && abs(value) < 1e6 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private func numberLineDescription() -> String {
        if let ops = operands, let op = op {
            return "Number line showing \(formatTick(ops.left)) \(op.rawValue) \(formatTick(ops.right)) equals \(formatTick(result))"
        }
        return "Number line showing result \(formatTick(result))"
    }
}
