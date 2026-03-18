import Foundation
import Testing
@testable import SundialCalculator

@Suite("History Persistence")
struct HistoryPersistenceTests {

    @Test("History persists across view model instances when enabled")
    func historyPersistsAcrossInstances() {
        let (defaults, suiteName) = makeDefaults()
        defer { clear(defaults, suiteName: suiteName) }

        let first = CalculatorViewModel(defaults: defaults, historyPersistenceEnabled: true, historyLimit: 50)
        first.appendCharacter("4")
        first.appendOperator(.add)
        first.appendCharacter("5")
        first.evaluate()
        first.appendCharacter("9")
        first.evaluate()

        let second = CalculatorViewModel(defaults: defaults, historyPersistenceEnabled: true, historyLimit: 50)
        #expect(second.history.count == 2)
        #expect(second.history[0].expression == "9")
        #expect(second.history[1].expression == "4 + 5")
    }

    @Test("Clear history removes persisted entries")
    func clearHistoryClearsPersistedState() {
        let (defaults, suiteName) = makeDefaults()
        defer { clear(defaults, suiteName: suiteName) }

        let first = CalculatorViewModel(defaults: defaults, historyPersistenceEnabled: true, historyLimit: 50)
        first.appendCharacter("7")
        first.evaluate()
        #expect(first.history.count == 1)

        first.clearHistory()

        let second = CalculatorViewModel(defaults: defaults, historyPersistenceEnabled: true, historyLimit: 50)
        #expect(second.history.isEmpty)
    }

    @Test("Persisted history respects the configured limit")
    func persistedHistoryRespectsLimit() {
        let (defaults, suiteName) = makeDefaults()
        defer { clear(defaults, suiteName: suiteName) }

        let first = CalculatorViewModel(defaults: defaults, historyPersistenceEnabled: true, historyLimit: 2)
        for digit in ["1", "2", "3"] {
            first.appendCharacter(digit)
            first.evaluate()
        }

        let second = CalculatorViewModel(defaults: defaults, historyPersistenceEnabled: true, historyLimit: 2)
        #expect(second.history.count == 2)
        #expect(second.history[0].formattedResult == "3")
        #expect(second.history[1].formattedResult == "2")
    }

    private func makeDefaults() -> (UserDefaults, String) {
        let suiteName = "HistoryPersistenceTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return (defaults, suiteName)
    }

    private func clear(_ defaults: UserDefaults, suiteName: String) {
        defaults.removePersistentDomain(forName: suiteName)
    }
}
