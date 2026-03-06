import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: CalculatorViewModel
    @State private var showHistory = true

    var body: some View {
        HSplitView {
            if showHistory {
                HistoryView(viewModel: viewModel)
                    .frame(minWidth: 160, idealWidth: 200, maxWidth: 260)
            }

            VStack(spacing: 0) {
                DisplayView(viewModel: viewModel)

                if viewModel.showVisualAnswer, viewModel.lastResult != nil {
                    Divider()
                    VisualAnswerView(viewModel: viewModel)
                        .frame(height: 140)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Divider()

                KeypadView(viewModel: viewModel)
                    .padding(12)
            }
        }
        .background(.background)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showHistory.toggle()
                    }
                } label: {
                    Image(systemName: showHistory ? "sidebar.left" : "sidebar.left")
                        .symbolVariant(showHistory ? .none : .none)
                }
                .help("Toggle History Sidebar")
            }

            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showVisualAnswer.toggle()
                    }
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                }
                .help("Toggle Visual Answer")
            }
        }
        .onKeyPress(.return) {
            viewModel.evaluate()
            return .handled
        }
        .onKeyPress(.delete) {
            viewModel.backspace()
            return .handled
        }
        .onKeyPress(characters: .decimalDigits) { press in
            viewModel.handleKeyPress(String(press.characters))
            return .handled
        }
        .onKeyPress(characters: CharacterSet(charactersIn: "+-*/.%()=^")) { press in
            viewModel.handleKeyPress(String(press.characters))
            return .handled
        }
        .onKeyPress(.escape) {
            viewModel.clear()
            return .handled
        }
    }
}
