import Testing
@testable import SundialCalculator

@Suite("Confidence Check")
struct ConfidenceCheckTests {

    @Test("Binary operation produces estimate, direction, and sign checks")
    func binaryConfidenceCheck() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("4")
        vm.appendCharacter("8")
        vm.appendOperator(.add)
        vm.appendCharacter("1")
        vm.appendCharacter("7")
        vm.evaluate()

        let check = vm.confidenceCheck
        #expect(check != nil)
        #expect(check?.withinEstimate == true)
        #expect(check?.estimateText.contains("Estimate") == true)
        #expect(check?.directionText.contains("Direction check") == true)
        #expect(check?.signText.contains("Sign check") == true)
    }

    @Test("Complex expression still provides fallback confidence cues")
    func complexExpressionConfidenceCheck() {
        let vm = CalculatorViewModel()
        vm.appendParenthesis("(")
        vm.appendCharacter("1")
        vm.appendCharacter("0")
        vm.appendOperator(.add)
        vm.appendCharacter("5")
        vm.appendParenthesis(")")
        vm.appendOperator(.multiply)
        vm.appendCharacter("3")
        vm.evaluate()

        let check = vm.confidenceCheck
        #expect(vm.displayResult == "45")
        #expect(check != nil)
        #expect(check?.estimateText.contains("Rounded check") == true)
    }

    @Test("Clear removes confidence check state")
    func clearResetsConfidenceCheck() {
        let vm = CalculatorViewModel()
        vm.appendCharacter("9")
        vm.appendOperator(.subtract)
        vm.appendCharacter("4")
        vm.evaluate()
        #expect(vm.confidenceCheck != nil)

        vm.clear()
        #expect(vm.confidenceCheck == nil)
    }
}
