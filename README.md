# Sundial Calculator

A visual, Montessori-informed iPhone calculator designed for people with dyscalculia.

## Overview

Standard calculators return symbols, but many people with dyscalculia need **meaning** and **error resistance** as much as they need speed. Sundial Calculator provides a dual-output experience:

- **Symbolic output** — the expression and numeric result, always available
- **Visual output** — a "visual answer" that shows the same result through quantity, structure, and magnitude (number line jumps, place-value blocks, dot patterns, arrays, area models, and step-by-step constructions)

## Design Principles

Grounded in Montessori pedagogy and dyscalculia research:

- **Concrete-to-abstract progression** — start with quantity and structure, move to symbols when ready
- **Sensorial materials** — tappable, draggable manipulatives with spatial grouping and tactile cues
- **Self-correction (control of error)** — snap-to-place-value bins, regrouping rules, and inconsistency cues
- **Freedom within limits** — 2–3 visual options per operation, user-controlled pace, capped overlays
- **Reduce cognitive load** — progressive disclosure, user-paced steps, minimal motion

## Modes

- **Compute mode** (default) — fast entry, instant answer, compact visual check
- **Construct mode** (optional) — drag, group, and step through representations with control-of-error feedback

## Accessibility

Non-negotiable accessibility support:

- VoiceOver with custom actions for manipulatives
- Dynamic Type / Larger Text
- Sufficient contrast and color independence
- Dark Mode
- Reduced Motion alternatives
- 44pt minimum touch targets

## Tech Stack

- SwiftUI app shell
- SwiftUI Canvas for visual rendering
- UIKit interop for complex gesture workspaces (as needed)
- Core Data for local-first storage
- Optional CloudKit sync (private database, encrypted fields)

## Roadmap

| Phase | Focus |
|-------|-------|
| **MVP** | 4 operations, expression entry, history, one default visual per operation, full accessibility baseline, local-first |
| **v1** | Visual chooser (2–3 per operation), manipulatives, dot patterns, onboarding personalization |
| **v2** | Full Construct mode, guided step-by-step constructions, optional CloudKit sync, practice sets |

## Privacy

Local-first by default. No accounts required. Optional opt-in cloud sync with encrypted data at rest.

## License

All rights reserved.
