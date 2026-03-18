import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: CalculatorViewModel
    @State private var showHistory = true
    @State private var keyMonitor: Any?

    var body: some View {
        HSplitView {
            if showHistory {
                HistoryView(viewModel: viewModel)
                    .frame(minWidth: 160, idealWidth: 200, maxWidth: 260)
            }

            VStack(spacing: 0) {
                DisplayView(viewModel: viewModel)

                if viewModel.canReplay {
                    Divider()
                    HStack(spacing: 10) {
                        Button {
                            viewModel.replayPrevious()
                        } label: {
                            Image(systemName: "backward.frame")
                        }
                        .disabled(viewModel.currentStepIndex <= 0)
                        .help("Previous Step")
                        .accessibilityLabel("Replay previous step")

                        Button {
                            viewModel.toggleReplay()
                        } label: {
                            Image(systemName: viewModel.isReplayPlaying ? "pause.fill" : "play.fill")
                        }
                        .help(viewModel.isReplayPlaying ? "Pause Replay" : "Play Replay")
                        .accessibilityLabel(viewModel.isReplayPlaying ? "Pause replay" : "Play replay")

                        Button {
                            viewModel.replayNext()
                        } label: {
                            Image(systemName: "forward.frame")
                        }
                        .disabled((viewModel.trace?.steps.count ?? 0) <= 1 || viewModel.currentStepIndex >= ((viewModel.trace?.steps.count ?? 1) - 1))
                        .help("Next Step")
                        .accessibilityLabel("Replay next step")

                        Button {
                            viewModel.replayReset()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .disabled(viewModel.currentStepIndex == 0)
                        .help("Reset Replay")
                        .accessibilityLabel("Replay reset")

                        Spacer()
                    }
                    .buttonStyle(.borderless)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Replay controls")
                }

                if viewModel.showVisualAnswer, viewModel.visualResult != nil {
                    Divider()
                    VisualAnswerView(viewModel: viewModel)
                        .frame(minHeight: 140, maxHeight: 180)
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
                    Image(systemName: showHistory ? "sidebar.left" : "sidebar.right")
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
        .onAppear {
            NSApplication.shared.activate(ignoringOtherApps: true)
            installKeyMonitor()
        }
        .onDisappear { removeKeyMonitor() }
    }

    private func installKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Let menu shortcuts (Cmd+key) pass through
            if event.modifierFlags.contains(.command) { return event }

            switch event.keyCode {
            case 36: // Return
                viewModel.evaluate()
                return nil
            case 53: // Escape
                viewModel.clear()
                return nil
            case 51: // Delete / Backspace
                viewModel.backspace()
                return nil
            default:
                let chars = event.charactersIgnoringModifiers ?? ""
                if let char = chars.first {
                    let s = String(char)
                    if "0123456789.+-*/%^()=".contains(s) {
                        viewModel.handleKeyPress(s)
                        return nil
                    }
                }
            }
            return event
        }
    }

    private func removeKeyMonitor() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
}
