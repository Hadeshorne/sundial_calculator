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
                    ForEach(viewModel.availableVisualTypes, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Visual answer type")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            if let recommendation = viewModel.recommendedVisual, !viewModel.profile.reducedVisualComplexity {
                HStack(alignment: .top, spacing: 8) {
                    Text("Suggested: \(recommendation.type.rawValue)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(recommendation.reason)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Suggested visual: \(recommendation.type.rawValue). \(recommendation.reason)")
            }

            if viewModel.shouldShowVisualOnboarding {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(.yellow)
                        .padding(.top, 1)

                    Text(viewModel.visualOnboardingText)
                        .font(.caption2)
                        .foregroundStyle(.primary)
                        .lineLimit(viewModel.profile.reducedVisualComplexity ? 2 : 3)

                    Spacer(minLength: 8)

                    Button("Got it") {
                        viewModel.markVisualOnboardingSeen()
                    }
                    .font(.caption2.weight(.semibold))
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow.opacity(0.14))
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Visual onboarding. \(viewModel.visualOnboardingText)")
            }

            // Visual content
            Group {
                switch viewModel.selectedVisualType {
                case .numberLine:
                    NumberLineView(
                        result: viewModel.visualResult ?? 0,
                        operands: viewModel.visualOperands,
                        op: viewModel.visualOperator
                    )
                case .breakdown:
                    BreakdownView(value: viewModel.visualResult ?? 0)
                case .proportion:
                    ProportionBarView(
                        result: viewModel.visualResult ?? 0,
                        operands: viewModel.visualOperands,
                        op: viewModel.visualOperator
                    )
                case .orderOfMagnitude:
                    OrderOfMagnitudeView(
                        result: viewModel.visualResult ?? 0,
                        operands: viewModel.visualOperands,
                        op: viewModel.visualOperator
                    )
                case .areaGrid:
                    AreaGridView(
                        result: viewModel.visualResult ?? 0,
                        operands: viewModel.visualOperands,
                        op: viewModel.visualOperator
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
