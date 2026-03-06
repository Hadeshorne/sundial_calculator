// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SundialCalculator",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "SundialCalculator",
            path: "Sources/SundialCalculator"
        ),
        .testTarget(
            name: "SundialCalculatorTests",
            dependencies: ["SundialCalculator"],
            path: "Tests/SundialCalculatorTests"
        ),
    ]
)
