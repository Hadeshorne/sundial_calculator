import SwiftUI

struct VisualAnswerView: View {
    @Bindable var viewModel: CalculatorViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Visual type picker
            HStack {
                Text("Visual Check")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("", selection: $viewModel.selectedVisualType) {
                    ForEach(VisualAnswerType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
                .accessibilityLabel("Visual answer type")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Visual content
            Group {
                switch viewModel.selectedVisualType {
                case .numberLine:
                    NumberLineView(
                        result: viewModel.lastResult ?? 0,
                        operands: viewModel.lastOperands,
                        op: viewModel.lastOperator
                    )
                case .breakdown:
                    BreakdownView(value: viewModel.lastResult ?? 0)
                case .proportion:
                    ProportionBarView(
                        result: viewModel.lastResult ?? 0,
                        operands: viewModel.lastOperands,
                        op: viewModel.lastOperator
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.windowBackgroundColor).opacity(0.3))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Visual answer panel")
    }
}
