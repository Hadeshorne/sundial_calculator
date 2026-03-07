import SwiftUI

@main
struct SundialCalculatorApp: App {
    @State private var viewModel = CalculatorViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 600, minHeight: 500)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 780, height: 560)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandMenu("Calculator") {
                Button("Clear") { viewModel.clear() }
                    .keyboardShortcut("c", modifiers: [.command, .shift])
                Button("All Clear") { viewModel.allClear() }
                    .keyboardShortcut("a", modifiers: [.command, .shift])

                Divider()

                Button("Copy Result") { viewModel.copyResult() }
                    .keyboardShortcut("c", modifiers: .command)
                Button("Copy Expression") { viewModel.copyExpression() }
                    .keyboardShortcut("e", modifiers: [.command, .shift])
                Button("Paste") { viewModel.pasteExpression() }
                    .keyboardShortcut("v", modifiers: .command)

                Divider()

                Button("Toggle Visual Answer") {
                    viewModel.showVisualAnswer.toggle()
                }
                .keyboardShortcut("v", modifiers: [.command, .shift])
            }

            CommandMenu("Memory") {
                Button("Memory Add (M+)") { viewModel.memoryAdd() }
                Button("Memory Subtract (M−)") { viewModel.memorySubtract() }
                Button("Memory Recall (MR)") { viewModel.memoryRecall() }
                Button("Memory Clear (MC)") { viewModel.memoryClear() }
            }
        }
    }
}
