import SwiftUI

struct NumberLineView: View {
    let result: Double
    let operands: (left: Double, right: Double)?
    let op: Operator?
    @State private var jumpProgress: CGFloat = 1

    var body: some View {
        GeometryReader { geo in
            let axis = NumberLineMath.axis(for: axisValues())
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
                for value in axis.ticks {
                    let x = CGFloat(
                        NumberLineMath.xPosition(
                            for: value,
                            axis: axis,
                            padding: Double(padding),
                            width: Double(usableWidth)
                        )
                    )
                    let isZero = abs(value) < 0.0000001

                    // Tick
                    var tickPath = Path()
                    tickPath.move(to: CGPoint(x: x, y: lineY - (isZero ? 8 : 4)))
                    tickPath.addLine(to: CGPoint(x: x, y: lineY + (isZero ? 8 : 4)))
                    context.stroke(tickPath, with: .color(isZero ? .primary : .secondary), lineWidth: isZero ? 1.8 : 1)

                    // Label
                    let label = formatTick(value)
                    let text = Text(label)
                        .font(.system(size: isZero ? 11 : 10, weight: isZero ? .semibold : .regular, design: .monospaced))
                        .foregroundColor(isZero ? .primary : .secondary)
                    context.draw(text, at: CGPoint(x: x, y: lineY + 16))
                }

                // Draw operand markers if available
                if let ops = operands, let op = op {
                    let leftX = CGFloat(NumberLineMath.xPosition(for: ops.left, axis: axis, padding: Double(padding), width: Double(usableWidth)))
                    let resultX = CGFloat(NumberLineMath.xPosition(for: result, axis: axis, padding: Double(padding), width: Double(usableWidth)))
                    let animatedResultX = isDirectionalOperation(op) ? (leftX + (resultX - leftX) * jumpProgress) : resultX

                    // Left operand dot
                    let leftDot = Path(ellipseIn: CGRect(x: leftX - 4, y: lineY - 4, width: 8, height: 8))
                    context.fill(leftDot, with: .color(.blue))

                    // Arrow from left to result
                    let arrowY = lineY - 20
                    var arrow = Path()
                    arrow.move(to: CGPoint(x: leftX, y: lineY - 5))
                    arrow.addLine(to: CGPoint(x: leftX, y: arrowY))
                    arrow.addLine(to: CGPoint(x: animatedResultX, y: arrowY))
                    arrow.addLine(to: CGPoint(x: animatedResultX, y: lineY - 5))
                    context.stroke(arrow, with: .color(jumpColor(for: op)), lineWidth: 1.7)

                    // Jump label
                    let jumpLabel = jumpLabel(for: op, rightOperand: ops.right)
                    let jumpText = Text(jumpLabel).font(.system(size: 11, weight: .medium)).foregroundColor(jumpColor(for: op))
                    context.draw(jumpText, at: CGPoint(x: (leftX + animatedResultX) / 2, y: arrowY - 10))
                }

                // Result marker
                let resultX = CGFloat(NumberLineMath.xPosition(for: result, axis: axis, padding: Double(padding), width: Double(usableWidth)))
                let resultDot = Path(ellipseIn: CGRect(x: resultX - 5, y: lineY - 5, width: 10, height: 10))
                context.fill(resultDot, with: .color(.green))

                // Result label
                let resultLabel = Text(formatTick(result)).font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                context.draw(resultLabel, at: CGPoint(x: resultX, y: lineY - 14))
            }
        }
        .accessibilityElement()
        .accessibilityLabel(numberLineDescription())
        .onAppear { animateJump() }
        .onChange(of: result) { _, _ in animateJump() }
        .onChange(of: op) { _, _ in animateJump() }
        .onChange(of: operands?.left ?? 0) { _, _ in animateJump() }
        .onChange(of: operands?.right ?? 0) { _, _ in animateJump() }
    }

    private func axisValues() -> [Double] {
        var values: [Double] = [result]
        if let ops = operands {
            values.append(ops.left)
            values.append(ops.right)
        }
        return values
    }

    private func formatTick(_ value: Double) -> String {
        CalculatorEngine.formatResult(value)
    }

    private func isDirectionalOperation(_ op: Operator) -> Bool {
        op == .add || op == .subtract
    }

    private func jumpColor(for op: Operator) -> Color {
        switch op {
        case .add: return .green
        case .subtract: return .red
        case .multiply, .divide, .power: return .orange
        }
    }

    private func jumpLabel(for op: Operator, rightOperand: Double) -> String {
        switch op {
        case .add:
            return "+\(formatTick(abs(rightOperand)))"
        case .subtract:
            return "-\(formatTick(abs(rightOperand)))"
        default:
            return "\(op.rawValue)\(formatTick(rightOperand))"
        }
    }

    private func animateJump() {
        if let op, isDirectionalOperation(op), operands != nil {
            jumpProgress = 0
            withAnimation(.easeOut(duration: 0.65)) {
                jumpProgress = 1
            }
        } else {
            jumpProgress = 1
        }
    }

    private func numberLineDescription() -> String {
        if let ops = operands, let op = op {
            return "Number line showing \(formatTick(ops.left)) \(op.rawValue) \(formatTick(ops.right)) equals \(formatTick(result))"
        }
        return "Number line showing result \(formatTick(result))"
    }
}
