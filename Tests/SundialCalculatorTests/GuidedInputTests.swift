import Testing
@testable import SundialCalculator

@Suite("Guided Input")
struct GuidedInputTests {

    @Test("Guided mode prevents closing parenthesis without a matching open")
    func guidedBlocksInvalidCloseParen() {
        let vm = CalculatorViewModel()
        vm.setInputMode(.guided)
        vm.appendParenthesis(")")

        #expect(vm.expression == "")
        #expect(vm.guidedHint?.contains("Add a number") == true)
    }

    @Test("Guided mode prevents entering a new number immediately after percent")
    func guidedBlocksDigitAfterPercent() {
        let vm = CalculatorViewModel()
        vm.setInputMode(.guided)
        vm.appendCharacter("2")
        vm.appendCharacter("0")
        vm.appendPercent()
        vm.appendCharacter("5")

        #expect(vm.expression == "20%")
        #expect(vm.guidedHint?.contains("operator") == true)
    }

    @Test("Guided mode supports a valid number-operator-number flow")
    func guidedFlowEvaluates() {
        let vm = CalculatorViewModel()
        vm.setInputMode(.guided)
        vm.appendCharacter("1")
        vm.appendCharacter("2")
        vm.appendOperator(.add)
        vm.appendCharacter("3")
        vm.evaluate()

        #expect(vm.displayResult == "15")
        #expect(vm.errorMessage == nil)
    }

    @Test("Guided slots mirror expression structure")
    func guidedSlotsMirrorExpression() {
        let vm = CalculatorViewModel()
        vm.setInputMode(.guided)
        vm.appendCharacter("4")
        vm.appendOperator(.multiply)
        vm.appendSquareRoot()
        vm.appendCharacter("9")

        #expect(vm.guidedTokenSlots == ["4", "×", "√", "9"])
        #expect(vm.guidedNextSlotLabel.contains("operator") == true)
    }
}
