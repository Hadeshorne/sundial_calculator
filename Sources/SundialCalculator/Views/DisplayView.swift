import SwiftUI

struct DisplayView: View {
    @Bindable var viewModel: CalculatorViewModel

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Expression line
            Text(viewModel.expression.isEmpty ? " " : viewModel.expression)
                .font(.system(size: 20, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .accessibilityLabel("Expression: \(viewModel.expression.isEmpty ? "empty" : viewModel.expression)")

            // Result line
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 18))
                    .foregroundStyle(.red)
                    .accessibilityLabel("Error: \(error)")
            } else {
                Text(viewModel.displayResult.isEmpty ? "0" : viewModel.displayResult)
                    .font(.system(size: 42, weight: .light, design: .monospaced))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .accessibilityLabel("Result: \(viewModel.displayResult.isEmpty ? "zero" : viewModel.displayResult)")
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
}
