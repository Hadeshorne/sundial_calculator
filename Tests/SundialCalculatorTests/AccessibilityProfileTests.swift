import Foundation
import Testing
@testable import SundialCalculator

@Suite("Accessibility Profile", .serialized)
struct AccessibilityProfileTests {
    private let profileKey = "Sundial.AccessibilityProfile"
    private let onboardingKey = "Sundial.VisualOnboardingSeen"

    @Test("Profile toggles update runtime behavior")
    func profileTogglesRuntime() {
        let snapshot = snapshotDefaults()
        defer { restoreDefaults(snapshot) }
        clearDefaults()

        let vm = CalculatorViewModel()
        vm.setLargeTextEnabled(true)
        vm.setSimplifiedNotationEnabled(true)
        vm.setReducedVisualComplexityEnabled(true)
        vm.setSlowerAnimationsEnabled(false)

        #expect(vm.profile.largeText == true)
        #expect(vm.profile.simplifiedNotation == true)
        #expect(vm.profile.reducedVisualComplexity == true)
        #expect(vm.profile.slowerAnimations == false)
    }

    @Test("Profile persists across ViewModel instances")
    func profilePersistsAcrossInstances() {
        let snapshot = snapshotDefaults()
        defer { restoreDefaults(snapshot) }
        clearDefaults()

        let first = CalculatorViewModel()
        first.setLargeTextEnabled(true)
        first.setSimplifiedNotationEnabled(true)
        first.setReducedVisualComplexityEnabled(true)
        first.setSpokenMeaningChecksEnabled(true)

        let second = CalculatorViewModel()
        #expect(second.profile.largeText == true)
        #expect(second.profile.simplifiedNotation == true)
        #expect(second.profile.reducedVisualComplexity == true)
        #expect(second.profile.spokenMeaningChecks == true)
    }

    @Test("Visual onboarding is dismissible, persisted, and resettable")
    func visualOnboardingLifecycle() {
        let snapshot = snapshotDefaults()
        defer { restoreDefaults(snapshot) }
        clearDefaults()

        let first = CalculatorViewModel()
        first.selectedVisualType = .areaGrid
        first.appendCharacter("6")
        first.appendOperator(.multiply)
        first.appendCharacter("2")
        first.evaluate()

        #expect(first.shouldShowVisualOnboarding == true)
        first.markVisualOnboardingSeen()
        #expect(first.shouldShowVisualOnboarding == false)

        let second = CalculatorViewModel()
        second.selectedVisualType = .areaGrid
        second.appendCharacter("6")
        second.appendOperator(.multiply)
        second.appendCharacter("2")
        second.evaluate()
        #expect(second.shouldShowVisualOnboarding == false)

        second.resetVisualOnboarding()

        let third = CalculatorViewModel()
        third.selectedVisualType = .areaGrid
        third.appendCharacter("6")
        third.appendOperator(.multiply)
        third.appendCharacter("2")
        third.evaluate()
        #expect(third.shouldShowVisualOnboarding == true)
    }

    private func snapshotDefaults() -> (Data?, [String]?) {
        let defaults = UserDefaults.standard
        return (
            defaults.data(forKey: profileKey),
            defaults.stringArray(forKey: onboardingKey)
        )
    }

    private func clearDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: profileKey)
        defaults.removeObject(forKey: onboardingKey)
    }

    private func restoreDefaults(_ snapshot: (Data?, [String]?)) {
        let defaults = UserDefaults.standard
        if let profileData = snapshot.0 {
            defaults.set(profileData, forKey: profileKey)
        } else {
            defaults.removeObject(forKey: profileKey)
        }
        if let onboarding = snapshot.1 {
            defaults.set(onboarding, forKey: onboardingKey)
        } else {
            defaults.removeObject(forKey: onboardingKey)
        }
    }
}
