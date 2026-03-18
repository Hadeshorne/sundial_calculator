import SwiftUI

struct DisplayView: View {
    @Bindable var viewModel: CalculatorViewModel

    var body: some View {
        let expressionText = viewModel.profile.simplifiedNotation
            ? simplifiedExpression(viewModel.expression)
            : viewModel.expression
        let expressionSize: CGFloat = viewModel.profile.largeText ? 24 : 20
        let resultSize: CGFloat = viewModel.profile.largeText ? 50 : 42
        let reducedVisuals = viewModel.profile.reducedVisualComplexity

        VStack(alignment: .trailing, spacing: 4) {
            // Expression line
            Text(expressionText.isEmpty ? " " : expressionText)
                .font(.system(size: expressionSize, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .accessibilityLabel("Expression: \(expressionText.isEmpty ? "empty" : expressionText)")

            // Result line
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: viewModel.profile.largeText ? 22 : 18))
                    .foregroundStyle(.red)
                    .accessibilityLabel("Error: \(error)")
            } else {
                Text(viewModel.displayResult.isEmpty ? "0" : viewModel.displayResult)
                    .font(.system(size: resultSize, weight: .light, design: .monospaced))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .accessibilityLabel("Result: \(viewModel.displayResult.isEmpty ? "zero" : viewModel.displayResult)")
            }

            if viewModel.errorMessage == nil,
               let explanation = viewModel.explanation,
               !viewModel.displayResult.isEmpty {
                Text(explanation.text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(reducedVisuals ? 1 : 3)
                    .accessibilityLabel("Meaning check: \(explanation.text)")
            }

            if viewModel.errorMessage == nil,
               let stepText = viewModel.replayStepDescription,
               viewModel.canReplay {
                Text(stepText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .accessibilityLabel("Replay step: \(stepText)")
            }

            if viewModel.inputMode == .guided,
               viewModel.errorMessage == nil,
               let guidedHint = viewModel.guidedHint,
               !guidedHint.isEmpty {
                Text(guidedHint)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .accessibilityLabel("Guided hint: \(guidedHint)")
            }

            if viewModel.errorMessage == nil,
               let check = viewModel.confidenceCheck {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(check.withinEstimate ? "Estimate check: close match" : "Estimate check: large gap")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(check.withinEstimate ? .green : .orange)
                    Text(check.estimateText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if !reducedVisuals {
                        Text(check.directionText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Text(check.signText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.trailing)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Confidence check. \(check.estimateText) \(check.directionText) \(check.signText)")
            }

            // Memory indicator
            if viewModel.hasMemory {
                Text("M: \(CalculatorEngine.formatResult(viewModel.memory))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Memory: \(CalculatorEngine.formatResult(viewModel.memory))")
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.background.opacity(0.5))
    }

    private func simplifiedExpression(_ expression: String) -> String {
        expression
            .replacingOccurrences(of: "×", with: " times ")
            .replacingOccurrences(of: "÷", with: " divided by ")
            .replacingOccurrences(of: "−", with: " minus ")
            .replacingOccurrences(of: "+", with: " plus ")
            .replacingOccurrences(of: "^", with: " to the power of ")
            .replacingOccurrences(of: "√", with: " square root ")
    }
}
