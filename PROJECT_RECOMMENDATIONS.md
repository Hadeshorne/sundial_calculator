# the project's apparent purpose

`PUR-001` Sundial Calculator is trying to be a macOS calculator for senior executive knowledge workers that pairs fast symbolic entry with a visual sanity check, so users can verify magnitude, direction, and structure without adding cognitive overhead.

Evidence reviewed:
- `README.md`
- `CLAUDE.md`
- `Calculator_Research.md`
- `Sources/SundialCalculator/ViewModels/CalculatorViewModel.swift`
- `Sources/SundialCalculator/VisualAnswers/VisualAnswerView.swift`

# recommended feature improvements

`IMP-001` Reduce visual-choice clutter by making the visual picker context-aware instead of always showing every visual type.

Verifiable outcome:
- Addition and subtraction expose only the most relevant visuals.
- Multiplication, division, and power expose only multiplicative visuals.
- The picker shows at most three choices after evaluation.

`IMP-002` Strengthen the `Proportion` visual for multiplicative comparison so it can carry the bar-comparison job on its own.

Verifiable outcome:
- Multiplicative comparisons show scaled bars, a ratio label, and the computed result inside `Proportion`.
- No calculation loses a bar-based comparison view after the redundant visual is removed.

# recommended new features

`NEW-001` Persist calculation history across launches, with a bounded history size, because the current history is session-only even though the product targets ongoing professional workflows.

Verifiable outcome:
- Relaunching the app restores recent calculations in the same order.
- `Clear History` and `All Clear` also clear persisted history.
- Automated tests verify persistence and clearing behavior.

# recommended feature removals

`REM-001` Remove the standalone `Factor` visual from the user-facing feature set. It overlaps with `Proportion` for bar-based comparison and adds unnecessary choice burden against the product's own "freedom within limits" and cognitive-load goals.

Verifiable outcome:
- The app ships with five visual types instead of six.
- No `Factor` option appears in the picker, docs, or tests.
- Visual recommendations for multiplicative work route to `Proportion`, `Area`, or `Magnitude` instead.
