import Testing
@testable import SundialCalculator

@Suite("Number Line Math")
struct NumberLineMathTests {

    @Test("Axis always includes zero for positive values")
    func includesZeroPositive() {
        let axis = NumberLineMath.axis(for: [120, 180, 150])
        #expect(axis.min <= 0)
        #expect(axis.max >= 0)
        #expect(axis.ticks.contains(where: { abs($0) < 0.0001 }))
    }

    @Test("Axis always includes zero for negative values")
    func includesZeroNegative() {
        let axis = NumberLineMath.axis(for: [-30, -2, -14])
        #expect(axis.min <= 0)
        #expect(axis.max >= 0)
        #expect(axis.ticks.contains(where: { abs($0) < 0.0001 }))
    }

    @Test("Tick values are ascending and bounded")
    func tickOrdering() {
        let axis = NumberLineMath.axis(for: [-8, 0, 26])
        #expect(axis.ticks.count >= 4)
        #expect(axis.ticks.first! >= axis.min - 0.0001)
        #expect(axis.ticks.last! <= axis.max + 0.0001)
        for idx in 1..<axis.ticks.count {
            #expect(axis.ticks[idx] > axis.ticks[idx - 1])
        }
    }

    @Test("x position maps axis min and max to edges")
    func xMapping() {
        let axis = NumberLineAxis(min: -10, max: 10, ticks: [-10, 0, 10])
        let left = NumberLineMath.xPosition(for: -10, axis: axis, padding: 20, width: 200)
        let center = NumberLineMath.xPosition(for: 0, axis: axis, padding: 20, width: 200)
        let right = NumberLineMath.xPosition(for: 10, axis: axis, padding: 20, width: 200)
        #expect(left == 20)
        #expect(center == 120)
        #expect(right == 220)
    }
}
