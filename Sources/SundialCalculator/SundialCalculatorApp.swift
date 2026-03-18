import SwiftUI

@main
struct SundialCalculatorApp: App {
    @State private var viewModel = CalculatorViewModel(historyPersistenceEnabled: true)

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 640, minHeight: 540)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 820, height: 660)
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

            CommandMenu("Replay") {
                Button("Previous Step") { viewModel.replayPrevious() }
                    .keyboardShortcut("[", modifiers: .command)
                Button(viewModel.isReplayPlaying ? "Pause Replay" : "Play Replay") { viewModel.toggleReplay() }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
                Button("Next Step") { viewModel.replayNext() }
                    .keyboardShortcut("]", modifiers: .command)
                Button("Reset Replay") { viewModel.replayReset() }
                    .keyboardShortcut("r", modifiers: [.command, .shift])
            }

            CommandMenu("Input") {
                Button("\(checkmark(viewModel.inputMode == .freeform))Freeform") {
                    viewModel.setInputMode(.freeform)
                }
                .keyboardShortcut("1", modifiers: [.command, .option])

                Button("\(checkmark(viewModel.inputMode == .guided))Guided") {
                    viewModel.setInputMode(.guided)
                }
                .keyboardShortcut("2", modifiers: [.command, .option])
            }

            CommandMenu("Accessibility") {
                Toggle("Slower Replay Animation", isOn: Binding(
                    get: { viewModel.profile.slowerAnimations },
                    set: { viewModel.setSlowerAnimationsEnabled($0) }
                ))

                Toggle("Large Text", isOn: Binding(
                    get: { viewModel.profile.largeText },
                    set: { viewModel.setLargeTextEnabled($0) }
                ))

                Toggle("Simplified Notation Labels", isOn: Binding(
                    get: { viewModel.profile.simplifiedNotation },
                    set: { viewModel.setSimplifiedNotationEnabled($0) }
                ))

                Toggle("Spoken Meaning Checks", isOn: Binding(
                    get: { viewModel.profile.spokenMeaningChecks },
                    set: { viewModel.setSpokenMeaningChecksEnabled($0) }
                ))

                Toggle("Reduced Visual Complexity", isOn: Binding(
                    get: { viewModel.profile.reducedVisualComplexity },
                    set: { viewModel.setReducedVisualComplexityEnabled($0) }
                ))

                Divider()

                Button("Replay Visual Onboarding") {
                    viewModel.resetVisualOnboarding()
                }
            }
        }
    }

    private func checkmark(_ selected: Bool) -> String {
        selected ? "✓ " : ""
    }
}
