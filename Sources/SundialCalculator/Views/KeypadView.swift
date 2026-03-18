import SwiftUI

struct KeypadView: View {
    @Bindable var viewModel: CalculatorViewModel

    private var spacing: CGFloat { viewModel.profile.largeText ? 10 : 6 }
    private var keyHeight: CGFloat { viewModel.profile.largeText ? 52 : 44 }
    private var memoryHeight: CGFloat { viewModel.profile.largeText ? 40 : 32 }
    private var digitFontSize: CGFloat { viewModel.profile.largeText ? 24 : 20 }
    private var functionFontSize: CGFloat { viewModel.profile.largeText ? 18 : 16 }
    private var memoryFontSize: CGFloat { viewModel.profile.largeText ? 15 : 13 }

    var body: some View {
        VStack(spacing: spacing) {
            HStack(spacing: 8) {
                Text("Input")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Input Mode", selection: Binding(
                    get: { viewModel.inputMode },
                    set: { viewModel.setInputMode($0) }
                )) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 260)
                .accessibilityLabel("Input mode")

                Spacer()
            }

            if viewModel.inputMode == .guided {
                VStack(alignment: .leading, spacing: 6) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            if viewModel.guidedTokenSlots.isEmpty {
                                guidedSlot("number", isPlaceholder: true)
                                guidedSlot("operator", isPlaceholder: true)
                                guidedSlot("number", isPlaceholder: true)
                            } else {
                                ForEach(Array(viewModel.guidedTokenSlots.enumerated()), id: \.offset) { _, token in
                                    guidedSlot(token, isPlaceholder: false)
                                }
                                guidedSlot(viewModel.guidedNextSlotLabel.replacingOccurrences(of: "Next slot: ", with: ""), isPlaceholder: true)
                            }
                        }
                        .padding(.horizontal, 1)
                    }

                    Text(viewModel.guidedNextSlotLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Guided composer. \(viewModel.guidedNextSlotLabel)")
            }

            // Memory row
            HStack(spacing: spacing) {
                memoryButton("MC") { viewModel.memoryClear() }
                memoryButton("MR") { viewModel.memoryRecall() }
                memoryButton("M+") { viewModel.memoryAdd() }
                memoryButton("M−") { viewModel.memorySubtract() }
                functionButton("C") { viewModel.clear() }
            }

            // Row 1: ( ) √ ^ % ÷
            HStack(spacing: spacing) {
                functionButton("(") { viewModel.appendParenthesis("(") }
                functionButton(")") { viewModel.appendParenthesis(")") }
                functionButton("√") { viewModel.appendSquareRoot() }
                functionButton("^") { viewModel.appendPower() }
                functionButton("%") { viewModel.appendPercent() }
                operatorButton("÷") { viewModel.appendOperator(.divide) }
            }

            // Row 2: 7 8 9 ×
            HStack(spacing: spacing) {
                digitButton("7")
                digitButton("8")
                digitButton("9")
                operatorButton("×") { viewModel.appendOperator(.multiply) }
            }

            // Row 3: 4 5 6 −
            HStack(spacing: spacing) {
                digitButton("4")
                digitButton("5")
                digitButton("6")
                operatorButton("−") { viewModel.appendOperator(.subtract) }
            }

            // Row 4: 1 2 3 +
            HStack(spacing: spacing) {
                digitButton("1")
                digitButton("2")
                digitButton("3")
                operatorButton("+") { viewModel.appendOperator(.add) }
            }

            // Row 5: ± 0 . = ⌫
            HStack(spacing: spacing) {
                functionButton("±") { viewModel.toggleSign() }
                digitButton("0")
                digitButton(".")
                equalsButton()
                functionButton("⌫") { viewModel.backspace() }
            }
        }
    }

    // MARK: - Button Builders

    private func digitButton(_ label: String) -> some View {
        Button {
            if label == "." {
                viewModel.appendDecimal()
            } else {
                viewModel.appendCharacter(label)
            }
        } label: {
            Text(label)
                .font(.system(size: digitFontSize, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
        }
        .buttonStyle(CalcButtonStyle(kind: .digit))
        .accessibilityLabel(label == "." ? "Decimal point" : label)
    }

    private func operatorButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: digitFontSize, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
        }
        .buttonStyle(CalcButtonStyle(kind: .operator))
        .accessibilityLabel(operatorAccessibilityLabel(label))
    }

    private func functionButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: functionFontSize, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
        }
        .buttonStyle(CalcButtonStyle(kind: .function))
        .accessibilityLabel(functionAccessibilityLabel(label))
    }

    private func memoryButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: memoryFontSize, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: memoryHeight)
        }
        .buttonStyle(CalcButtonStyle(kind: .memory))
        .accessibilityLabel(memoryAccessibilityLabel(label))
    }

    private func equalsButton() -> some View {
        Button { viewModel.evaluate() } label: {
            Text("=")
                .font(.system(size: digitFontSize + 2, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
        }
        .buttonStyle(CalcButtonStyle(kind: .equals))
        .accessibilityLabel("Equals")
    }

    private func guidedSlot(_ text: String, isPlaceholder: Bool) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundStyle(isPlaceholder ? .secondary : .primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(
                        isPlaceholder
                            ? Color(.controlBackgroundColor).opacity(0.45)
                            : Color.accentColor.opacity(0.16)
                    )
            )
    }

    // MARK: - Accessibility Labels

    private func operatorAccessibilityLabel(_ label: String) -> String {
        switch label {
        case "÷": return "Divide"
        case "×": return "Multiply"
        case "−": return "Subtract"
        case "+": return "Add"
        default: return label
        }
    }

    private func functionAccessibilityLabel(_ label: String) -> String {
        switch label {
        case "(": return "Open parenthesis"
        case ")": return "Close parenthesis"
        case "%": return "Percent"
        case "C": return "Clear"
        case "√": return "Square root"
        case "^": return "Power"
        case "±": return "Toggle sign"
        case "⌫": return "Backspace"
        default: return label
        }
    }

    private func memoryAccessibilityLabel(_ label: String) -> String {
        switch label {
        case "MC": return "Memory clear"
        case "MR": return "Memory recall"
        case "M+": return "Memory add"
        case "M−": return "Memory subtract"
        default: return label
        }
    }
}

// MARK: - Button Style

enum CalcButtonKind {
    case digit, `operator`, function, equals, memory
}

struct CalcButtonStyle: ButtonStyle {
    let kind: CalcButtonKind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
    }

    private var foregroundColor: Color {
        switch kind {
        case .digit: return .primary
        case .operator: return .white
        case .function: return .primary
        case .equals: return .white
        case .memory: return .secondary
        }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        let base: Color = {
            switch kind {
            case .digit: return Color(.controlBackgroundColor)
            case .operator: return .orange
            case .function: return Color(.controlBackgroundColor).opacity(0.6)
            case .equals: return .blue
            case .memory: return Color(.controlBackgroundColor).opacity(0.3)
            }
        }()
        return isPressed ? base.opacity(0.7) : base
    }
}
