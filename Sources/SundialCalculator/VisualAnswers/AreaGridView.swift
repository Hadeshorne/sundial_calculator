import SwiftUI

struct AreaGridView: View {
    let result: Double
    let operands: (left: Double, right: Double)?
    let op: Operator?

    var body: some View {
        if let ops = operands, (op == .multiply || op == .divide || op == .power) {
            gridDisplay(ops: ops)
        } else {
            fallbackDisplay()
        }
    }

    // MARK: - Grid display for multiply/divide/power

    @ViewBuilder
    private func gridDisplay(ops: (left: Double, right: Double)) -> some View {
        let grid = computeGrid(ops: ops)

        GeometryReader { geo in
            Canvas { context, size in
                let padding: CGFloat = 12
                let labelSpace: CGFloat = 40
                let gridLeft = padding + labelSpace
                let gridTop: CGFloat = padding + 20
                let availableWidth = size.width - gridLeft - padding
                let availableHeight = size.height - gridTop - padding - 16

                guard grid.cols > 0 && grid.rows > 0 else { return }

                let cellWidth = min(availableWidth / CGFloat(grid.cols), 24)
                let cellHeight = min(availableHeight / CGFloat(grid.rows), 24)
                let cellSize = min(cellWidth, cellHeight)

                let gridWidth = cellSize * CGFloat(grid.cols)
                let gridHeight = cellSize * CGFloat(grid.rows)

                // Draw grid cells
                for row in 0..<grid.rows {
                    for col in 0..<grid.cols {
                        let x = gridLeft + CGFloat(col) * cellSize
                        let y = gridTop + CGFloat(row) * cellSize
                        let rect = CGRect(x: x, y: y, width: cellSize - 1, height: cellSize - 1)

                        let isPartialCol = grid.partialCol && col == grid.cols - 1
                        let isPartialRow = grid.partialRow && row == grid.rows - 1

                        let opacity: Double = (isPartialCol || isPartialRow) ? 0.35 : 0.6
                        context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(.blue.opacity(opacity)))
                    }
                }

                // Column label (left operand)
                let colLabel: String
                if op == .divide {
                    colLabel = "\(CalculatorEngine.formatResult(result)) cols"
                } else {
                    colLabel = "\(CalculatorEngine.formatResult(ops.left)) cols"
                }
                let colText = Text(colLabel).font(.system(size: 10, weight: .medium)).foregroundColor(.blue)
                context.draw(colText, at: CGPoint(x: gridLeft + gridWidth / 2, y: gridTop - 10))

                // Row label (right operand)
                let rowLabel: String
                if op == .divide {
                    rowLabel = "\(CalculatorEngine.formatResult(ops.right))"
                } else {
                    rowLabel = "\(CalculatorEngine.formatResult(ops.right))"
                }
                let rowText = Text(rowLabel).font(.system(size: 10, weight: .medium)).foregroundColor(.orange)
                context.draw(rowText, at: CGPoint(x: padding + labelSpace / 2, y: gridTop + gridHeight / 2))
                let rowSuffix = Text("rows").font(.system(size: 9)).foregroundColor(.secondary)
                context.draw(rowSuffix, at: CGPoint(x: padding + labelSpace / 2, y: gridTop + gridHeight / 2 + 12))

                // Result label
                let resultStr = "= \(CalculatorEngine.formatResult(result))"
                let resultText = Text(resultStr).font(.system(size: 12, weight: .bold)).foregroundColor(.green)
                context.draw(resultText, at: CGPoint(x: gridLeft + gridWidth / 2, y: gridTop + gridHeight + 10))

                // Scale legend if cells are grouped
                if grid.scale > 1 {
                    let scaleStr = "each cell = \(formatScale(grid.scale))"
                    let scaleText = Text(scaleStr).font(.system(size: 9)).foregroundColor(.secondary)
                    context.draw(scaleText, at: CGPoint(x: size.width - padding - 40, y: size.height - padding))
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel(gridDescription())
    }

    // MARK: - Fallback for non-multiplicative operations

    @ViewBuilder
    private func fallbackDisplay() -> some View {
        let absResult = abs(result)

        GeometryReader { geo in
            let barWidth = geo.size.width * 0.7

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.blue.opacity(0.6))
                    .frame(width: barWidth, height: 28)
                    .overlay {
                        Text(CalculatorEngine.formatResult(result))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }

                if absResult > 0, absResult < 1e12 {
                    let sqrtApprox = sqrt(absResult)
                    Text("\u{2248} \(CalculatorEngine.formatResult(sqrtApprox)) \u{00D7} \(CalculatorEngine.formatResult(sqrtApprox))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
        }
        .accessibilityElement()
        .accessibilityLabel(gridDescription())
    }

    // MARK: - Grid computation

    private struct GridSpec {
        let cols: Int
        let rows: Int
        let scale: Double
        let partialCol: Bool
        let partialRow: Bool
    }

    private func computeGrid(ops: (left: Double, right: Double)) -> GridSpec {
        let leftAbs = abs(ops.left)
        let rightAbs = abs(ops.right)

        let (colVal, rowVal): (Double, Double)
        if op == .divide {
            // For division: result columns × divisor rows = dividend
            colVal = abs(result)
            rowVal = rightAbs
        } else {
            colVal = leftAbs
            rowVal = rightAbs
        }

        guard colVal > 0 && rowVal > 0 else {
            return GridSpec(cols: 0, rows: 0, scale: 1, partialCol: false, partialRow: false)
        }

        // Find a scale so the grid fits within max ~12×12
        let maxDim = 12.0
        var scale = 1.0

        if colVal > maxDim || rowVal > maxDim {
            let scaleNeeded = max(colVal / maxDim, rowVal / maxDim)
            // Round scale to a nice number
            let magnitude = pow(10, floor(log10(scaleNeeded)))
            let normalized = scaleNeeded / magnitude
            if normalized <= 1 { scale = magnitude }
            else if normalized <= 2 { scale = 2 * magnitude }
            else if normalized <= 5 { scale = 5 * magnitude }
            else { scale = 10 * magnitude }
        }

        let scaledCols = colVal / scale
        let scaledRows = rowVal / scale

        let cols = max(1, Int(ceil(scaledCols)))
        let rows = max(1, Int(ceil(scaledRows)))

        let partialCol = scaledCols != floor(scaledCols) && scaledCols > 1
        let partialRow = scaledRows != floor(scaledRows) && scaledRows > 1

        return GridSpec(
            cols: min(cols, 15),
            rows: min(rows, 12),
            scale: scale,
            partialCol: partialCol,
            partialRow: partialRow
        )
    }

    // MARK: - Formatting

    private func formatScale(_ scale: Double) -> String {
        if scale >= 1e9 { return "\(String(format: "%.0f", scale / 1e9))B" }
        if scale >= 1e6 { return "\(String(format: "%.0f", scale / 1e6))M" }
        if scale >= 1e3 { return "\(String(format: "%.0f", scale / 1e3))K" }
        return CalculatorEngine.formatResult(scale)
    }

    private func gridDescription() -> String {
        if let ops = operands, let op = op {
            return "Area grid: \(CalculatorEngine.formatResult(ops.left)) \(op.rawValue) \(CalculatorEngine.formatResult(ops.right)) equals \(CalculatorEngine.formatResult(result))"
        }
        return "Area view showing \(CalculatorEngine.formatResult(result))"
    }
}
