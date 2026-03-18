import Testing
@testable import SundialCalculator

@Suite("Place Value Model")
struct PlaceValueModelTests {

    @Test("Whole number decomposition includes expected places")
    func wholeNumberDecomposition() {
        let parts = PlaceValueModel.decompose(1234)
        #expect(parts.map(\.label) == ["thousands", "hundreds", "tens", "ones"])
        #expect(parts.map(\.valueText) == ["1000", "200", "30", "4"])
    }

    @Test("Decimal decomposition includes tenths and hundredths")
    func decimalDecomposition() {
        let parts = PlaceValueModel.decompose(12.34)
        #expect(parts.map(\.label).contains("tenths"))
        #expect(parts.map(\.label).contains("hundredths"))
        #expect(parts.first(where: { $0.label == "tenths" })?.valueText == "0.3")
        #expect(parts.first(where: { $0.label == "hundredths" })?.valueText == "0.04")
    }

    @Test("Negative values preserve sign in contributions")
    func negativeDecomposition() {
        let parts = PlaceValueModel.decompose(-45.2)
        #expect(parts.first(where: { $0.label == "tens" })?.contribution == -40)
        #expect(parts.first(where: { $0.label == "ones" })?.contribution == -5)
        #expect(parts.first(where: { $0.label == "tenths" })?.contribution == -0.2)
    }
}
