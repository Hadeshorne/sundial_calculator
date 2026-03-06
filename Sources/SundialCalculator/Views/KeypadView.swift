import SwiftUI

struct KeypadView: View {
    @Bindable var viewModel: CalculatorViewModel

    private let spacing: CGFloat = 6

    var body: some View {
        VStack(spacing: spacing) {
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
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(CalcButtonStyle(kind: .digit))
        .accessibilityLabel(label == "." ? "Decimal point" : label)
    }

    private func operatorButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(CalcButtonStyle(kind: .operator))
        .accessibilityLabel(operatorAccessibilityLabel(label))
    }

    private func functionButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(CalcButtonStyle(kind: .function))
        .accessibilityLabel(functionAccessibilityLabel(label))
    }

    private func memoryButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 32)
        }
        .buttonStyle(CalcButtonStyle(kind: .memory))
        .accessibilityLabel(memoryAccessibilityLabel(label))
    }

    private func equalsButton() -> some View {
        Button { viewModel.evaluate() } label: {
            Text("=")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(CalcButtonStyle(kind: .equals))
        .accessibilityLabel("Equals")
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
