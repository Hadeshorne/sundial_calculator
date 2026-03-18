import Foundation

struct NumberLineAxis: Equatable {
    let min: Double
    let max: Double
    let ticks: [Double]
}

enum NumberLineMath {
    static func axis(for values: [Double], desiredTickCount: Int = 7) -> NumberLineAxis {
        let finiteValues = values.filter(\.isFinite)
        guard let rawMin = finiteValues.min(), let rawMax = finiteValues.max() else {
            return NumberLineAxis(min: -1, max: 1, ticks: [-1, 0, 1])
        }

        // Keep a fixed zero anchor so users can orient direction/magnitude quickly.
        var minBound = min(rawMin, 0)
        var maxBound = max(rawMax, 0)
        var span = max(maxBound - minBound, 1)
        let padding = span * 0.18
        minBound -= padding
        maxBound += padding
        minBound = min(minBound, 0)
        maxBound = max(maxBound, 0)

        span = max(maxBound - minBound, 1)
        let targetTickCount = max(4, desiredTickCount)
        let roughStep = span / Double(targetTickCount - 1)
        let tickStep = niceStep(roughStep)

        let alignedMin = floor(minBound / tickStep) * tickStep
        let alignedMax = ceil(maxBound / tickStep) * tickStep

        var ticks: [Double] = []
        var value = alignedMin
        // Include tiny epsilon to ensure alignedMax is represented when floating-point drifts.
        while value <= alignedMax + (tickStep / 1000) {
            ticks.append(value)
            value += tickStep
            if ticks.count > 15 { break }
        }

        if !ticks.contains(where: { abs($0) < (tickStep / 1000) }) {
            ticks.append(0)
            ticks.sort()
        }

        return NumberLineAxis(min: alignedMin, max: alignedMax, ticks: ticks)
    }

    static func xPosition(for value: Double, axis: NumberLineAxis, padding: Double, width: Double) -> Double {
        let clampedRange = max(axis.max - axis.min, 1e-12)
        let fraction = (value - axis.min) / clampedRange
        let clamped = min(max(fraction, 0), 1)
        return padding + (width * clamped)
    }

    private static func niceStep(_ value: Double) -> Double {
        guard value.isFinite, value > 0 else { return 1 }
        let exponent = floor(log10(value))
        let base = pow(10, exponent)
        let normalized = value / base

        let niceNormalized: Double
        if normalized <= 1 {
            niceNormalized = 1
        } else if normalized <= 2 {
            niceNormalized = 2
        } else if normalized <= 5 {
            niceNormalized = 5
        } else {
            niceNormalized = 10
        }

        return niceNormalized * base
    }
}
