import Testing
@testable import SundialCalculator

@Suite("Computation Trace")
struct ComputationTraceTests {

    @Test("Trace captures operator-precedence steps")
    func precedenceTrace() throws {
        let trace = try CalculatorEngine.evaluateWithTrace("2 + 3 × 4")
        #expect(trace.finalResult == 14)
        #expect(trace.steps.count == 2)
        #expect(trace.steps[0].op == .multiply)
        #expect(trace.steps[0].left == 3)
        #expect(trace.steps[0].right == 4)
        #expect(trace.steps[0].result == 12)
        #expect(trace.steps[1].op == .add)
        #expect(trace.steps[1].left == 2)
        #expect(trace.steps[1].right == 12)
        #expect(trace.steps[1].result == 14)
    }

    @Test("Trace respects parentheses order")
    func parenthesizedTrace() throws {
        let trace = try CalculatorEngine.evaluateWithTrace("(2 + 3) × 4")
        #expect(trace.finalResult == 20)
        #expect(trace.steps.count == 2)
        #expect(trace.steps[0].op == .add)
        #expect(trace.steps[1].op == .multiply)
        #expect(trace.steps[1].left == 5)
        #expect(trace.steps[1].right == 4)
    }

    @Test("Single-number expression has no replay steps")
    func singleNumberTrace() throws {
        let trace = try CalculatorEngine.evaluateWithTrace("42")
        #expect(trace.finalResult == 42)
        #expect(trace.steps.isEmpty)
        #expect(trace.hasReplayableSteps == false)
    }

    @Test("Trace summary text is readable")
    func summaryText() throws {
        let trace = try CalculatorEngine.evaluateWithTrace("10 ÷ 2")
        #expect(trace.steps.count == 1)
        #expect(trace.steps[0].summary == "10 ÷ 2 = 5")
    }
}
