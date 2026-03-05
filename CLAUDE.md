# Sundial Calculator — Project Guide

## Project Overview

Sundial Calculator is a visual, Montessori-informed iPhone calculator for people with dyscalculia. It provides dual-output (symbolic + visual) computation with an emphasis on meaning, error resistance, and accessibility.

## Architecture

- **Platform**: iOS (iPhone)
- **UI Framework**: SwiftUI (app shell) + SwiftUI Canvas (visual rendering) + UIKit interop (complex gestures)
- **Storage**: Core Data (local-first), optional CloudKit sync
- **Pattern**: Modular — computation engine, visual renderer(s), interaction layer, accessibility adapter

## Key Design Constraints

- **Montessori principles are engineering constraints**, not decoration:
  - Concrete-to-abstract progression
  - Sensorial (perceptual, tappable, draggable) materials
  - Self-correction / control of error built into the UI
  - Freedom within limits (bounded choices: 2–3 visual options per operation)
  - Limit the field of consciousness (progressive disclosure)
- **Cognitive load reduction** is a product requirement, not a nice-to-have
- **Accessibility is non-negotiable**: VoiceOver, Dynamic Type, contrast, Dark Mode, Reduced Motion, 44pt touch targets

## Two Modes

- **Compute mode** (default): fast entry, instant result, compact visual check
- **Construct mode**: interactive manipulatives with control-of-error feedback

## Visual Answer Types

- Number line (animated jumps with step controls)
- Manipulatives (base-ten blocks / bead units)
- Dot patterns (ten-frames, canonical dot cards)
- Arrays / area models
- Color-coded place value (with non-color fallbacks)
- Step-by-step animated constructions

## Code Style

- Swift, following Apple's Swift API Design Guidelines
- SwiftUI-first, UIKit only when needed for performance or gesture complexity
- Accessibility modifiers on every interactive element
- Test at accessibility text sizes and with VoiceOver before merging

## File Structure (planned)

```
SundialCalculator/
├── App/                    # App entry point, main scenes
├── Models/                 # Data models, computation engine
├── Views/
│   ├── Calculator/         # Keypad, expression display, result
│   ├── VisualAnswers/      # Number line, manipulatives, dot patterns, etc.
│   └── Settings/           # Preferences, accessibility options
├── ViewModels/             # State management
├── Services/               # Storage, CloudKit sync, haptics
├── Accessibility/          # VoiceOver helpers, custom actions
└── Resources/              # Assets, localization
```

## Development Workflow

- Run tests before committing
- Test accessibility (VoiceOver, Dynamic Type, Reduced Motion) for any UI change
- Keep visual renderers as interchangeable modules that all obey the truth constraint: visual model must match computed result

## Reference

See `deep-research-report.md` for the full design research document including evidence base, wireframes, evaluation plan, and roadmap.
