import SwiftUI

struct BreakdownView: View {
    let value: Double
    @State private var phase: PlaceValuePhase = .after
    @State private var phaseToken = UUID()

    var body: some View {
        let parts = PlaceValueModel.decompose(value)

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Place Value • \(phase.rawValue)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                    VStack(spacing: 4) {
                        Text(part.label)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(colorForMagnitude(part.magnitude))
                            .frame(
                                width: adjustedWidth(for: part),
                                height: part.magnitude < 1 ? 34 : 40
                            )
                            .overlay {
                                Text(part.valueText)
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .minimumScaleFactor(0.6)
                                    .lineLimit(1)
                            }

                        if index < parts.count - 1 {
                            Text("+")
                                .font(.system(size: 12))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                if !parts.isEmpty {
                    VStack(spacing: 4) {
                        Text("")
                            .font(.system(size: 10))
                        Text("=")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text("")
                            .font(.system(size: 10))
                    }

                    VStack(spacing: 4) {
                        Text("Total")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.green.opacity(0.8))
                            .frame(width: 72, height: 40)
                            .overlay {
                                Text(CalculatorEngine.formatResult(value))
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }
                        Text("")
                            .font(.system(size: 10))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.2), value: phase)
        .accessibilityElement()
        .accessibilityLabel(breakdownDescription())
        .onAppear { animatePhases() }
        .onChange(of: value) { _, _ in animatePhases() }
    }

    private func adjustedWidth(for part: PlaceValuePart) -> CGFloat {
        let base = max(34, CGFloat(part.proportion) * 220)
        switch phase {
        case .before:
            return base * 0.93
        case .regroup:
            return base * 1.04
        case .after:
            return base
        }
    }

    private func animatePhases() {
        let token = UUID()
        phaseToken = token
        phase = .before

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) { [token] in
            guard phaseToken == token else { return }
            withAnimation(.easeInOut(duration: 0.18)) {
                phase = .regroup
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.44) { [token] in
            guard phaseToken == token else { return }
            withAnimation(.easeInOut(duration: 0.18)) {
                phase = .after
            }
        }
    }

    private func colorForMagnitude(_ magnitude: Double) -> Color {
        switch magnitude {
        case 1_000_000_000: return .purple
        case 1_000_000: return .indigo
        case 1_000: return .blue
        case 100: return .teal
        case 10: return .orange
        case 1: return .red.opacity(0.82)
        case 0.1: return .pink
        case 0.01: return .mint
        default: return .gray
        }
    }

    private func breakdownDescription() -> String {
        let parts = PlaceValueModel.decompose(value)
        if parts.isEmpty { return "Place value breakdown of \(CalculatorEngine.formatResult(value))" }
        let partDescs = parts.map { "\($0.valueText) \($0.label)" }
        return "Place value: \(partDescs.joined(separator: " plus ")) equals \(CalculatorEngine.formatResult(value))"
    }
}
