import SwiftUI

struct HistoryView: View {
    @Bindable var viewModel: CalculatorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("History")
                    .font(.headline)
                Spacer()
                if !viewModel.history.isEmpty {
                    Button("Clear") { viewModel.clearHistory() }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            if viewModel.history.isEmpty {
                VStack {
                    Spacer()
                    Text("No calculations yet")
                        .foregroundStyle(.tertiary)
                        .font(.callout)
                    Text("Results will appear here")
                        .foregroundStyle(.quaternary)
                        .font(.caption)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(viewModel.history) { record in
                            HistoryRow(record: record)
                                .onTapGesture {
                                    viewModel.recallFromHistory(record)
                                }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
        .background(Color(.windowBackgroundColor).opacity(0.5))
        .accessibilityLabel("Calculation history")
    }
}

struct HistoryRow: View {
    let record: CalculationRecord

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(record.expression)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text("= \(record.formattedResult)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.controlBackgroundColor).opacity(0.3))
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.expression) equals \(record.formattedResult)")
        .accessibilityHint("Tap to recall this calculation")
    }
}
