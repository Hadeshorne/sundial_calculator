# Sundial Calculator — User Manual

## What is Sundial Calculator?

Sundial Calculator is a macOS desktop calculator that shows you both the numeric answer and a visual representation of your result. It's designed for quick, accurate calculation with built-in visual verification — so you can see at a glance whether a result "looks right."

---

## Setup

### Requirements
- A Mac running macOS 14 (Sonoma) or later
- Xcode Command Line Tools installed

### Installing Xcode Command Line Tools
If you haven't installed them before, open Terminal (found in Applications → Utilities) and run:
```bash
xcode-select --install
```
Follow the on-screen prompts. This is a one-time setup.

### Getting the App Ready
1. Open **Terminal** (Applications → Utilities → Terminal)
2. Navigate to the project folder:
   ```bash
   cd /path/to/Sundial_Calculator
   ```
3. Build the app:
   ```bash
   swift build
   ```
   Wait for "Build complete!" to appear.

### Launching the App
Run this command in Terminal:
```bash
swift run
```
A calculator window will appear on screen.

---

## The Interface

When the app launches, you'll see three main areas:

```
┌──────────────┬──────────────────────────────────┐
│              │  Expression: what you're typing   │
│   History    │  Result: the answer               │
│   Sidebar    │                                   │
│              │  Visual Answer Panel               │
│              │  (number line, bars, or blocks)    │
│              │                                   │
│              │  ┌──────────────────────────────┐ │
│              │  │        Calculator Keypad      │ │
│              │  └──────────────────────────────┘ │
└──────────────┴──────────────────────────────────┘
```

1. **History Sidebar** (left) — shows your past calculations
2. **Display** (top right) — shows what you're typing and the result
3. **Visual Answer Panel** (middle right) — a visual picture of your result
4. **Keypad** (bottom right) — buttons for numbers and operations

---

## Basic Usage

### Entering a Calculation

**With the keyboard (fastest):**
Just type your calculation directly. For example, type:
```
5+3
```
Then press **Enter** to get the answer: **8**

**With the mouse:**
Click the number and operator buttons on the keypad, then click **=**.

### Operations

| What you want | Keyboard | Button |
|---------------|----------|--------|
| Add | `+` | + |
| Subtract | `-` | − |
| Multiply | `*` | × |
| Divide | `/` | ÷ |
| Power (exponent) | `^` | ^ |
| Square root | — | √ |
| Equals | `Enter` | = |
| Decimal point | `.` | . |
| Percent | `%` | % |
| Parentheses | `(` and `)` | ( and ) |

### Examples

| Type this | Result |
|-----------|--------|
| `12+8` then Enter | 20 |
| `100/4` then Enter | 25 |
| `(10+5)*3` then Enter | 45 |
| `200+10%` then Enter | 220 (adds 10% of 200) |
| `50%` then Enter | 0.5 (50% as a decimal) |
| `5^2` then Enter | 25 (5 squared) |
| `1.05^10` then Enter | ≈1.629 (compound interest factor) |
| Click `√` then type `144` then Enter | 12 (square root of 144) |

---

## Editing Your Input

| Action | Keyboard | Button |
|--------|----------|--------|
| Delete last character | `Delete` | ⌫ |
| Clear everything | `Escape` | C |
| Change sign (positive/negative) | — | ± |

---

## Visual Answer Panel

After every calculation, a visual representation appears below the result. This helps you quickly verify the answer makes sense.

### Three Visual Types

Click the segmented control to switch between them:

1. **Number Line** — Shows your operands and result as points on a line with an arc showing the operation. Good for addition and subtraction.

2. **Place Value** — Breaks the result into thousands, hundreds, tens, and ones with color-coded blocks. Good for understanding large numbers.

3. **Proportion** — Shows how the operands relate to the result as colored bars. Good for seeing relative sizes.

### Hiding the Visual Panel
If you just want a simple calculator, click the chart icon (📊) in the toolbar to hide the visual panel. Click it again to bring it back.

---

## History

Every calculation you make is saved in the left sidebar.

- **Newest calculations appear at the top**
- **Click any entry** to load that calculation back into the display
- **Click "Clear"** in the history header to erase all history

### Hiding the History Sidebar
Click the sidebar icon in the toolbar to toggle the history panel.

---

## Memory Functions

Memory lets you store a number and recall it later — useful for running totals.

| Button | What it does |
|--------|-------------|
| **M+** | Adds the current result to memory |
| **M−** | Subtracts the current result from memory |
| **MR** | Puts the memory value into your current expression |
| **MC** | Clears the memory |

When memory has a value stored, you'll see **M: (value)** below the result.

**Example workflow:**
1. Calculate `100*3` → 300
2. Click **M+** (memory now holds 300)
3. Calculate `50*4` → 200
4. Click **M+** (memory now holds 500)
5. Click **C** to clear, then click **MR** → "500" appears in your expression

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `0`–`9` | Enter digits |
| `+` `-` `*` `/` | Operations |
| `^` | Power (exponent) |
| `.` | Decimal point |
| `%` | Percent |
| `(` `)` | Parentheses |
| `Enter` | Calculate result |
| `Escape` | Clear expression |
| `Delete` | Backspace |
| `Cmd+C` | Copy result to clipboard |
| `Cmd+Shift+C` | Clear expression |
| `Cmd+Shift+A` | All clear (expression + history + memory) |
| `Cmd+Shift+V` | Toggle visual answer panel |

---

## Menu Bar

The app adds two menus to the menu bar:

**Calculator menu:**
- Clear, All Clear
- Copy Result
- Toggle Visual Answer

**Memory menu:**
- Memory Add, Subtract, Recall, Clear

---

## Tips

- **Chain calculations**: After getting a result, press an operator key (+, −, etc.) to continue calculating from that result
- **Parentheses**: Use them to control order of operations. `(10+5)*3` = 45, but `10+5*3` = 25
- **Power**: Use `^` for exponents. `2^10` = 1024. Great for compound interest: `1000*1.05^10` tells you what $1000 becomes at 5% annual growth over 10 years
- **Square root**: Click the `√` button then type a number. `√144` = 12. Note: square root of a negative number will show an error
- **Percentage shortcut**: `200+10%` automatically calculates "200 plus 10% of 200" = 220. This works with subtraction too: `200-10%` = 180
- **Copy results**: Press `Cmd+C` to copy the result and paste it into other apps
- **Visual check**: If a result seems wrong, glance at the visual panel — a number line or proportion bar can quickly reveal order-of-magnitude errors

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Window doesn't appear | Make sure `swift build` succeeded before running `swift run` |
| "Cannot divide by zero" | You tried to divide by zero — change the divisor |
| "Undefined result" | You tried an impossible operation like the square root of a negative number, or a power that produces infinity |
| "Invalid expression" | Check for misplaced operators or unsupported characters |
| "Mismatched parentheses" | Make sure every `(` has a matching `)` |
| Build fails | Run `xcode-select --install` to install developer tools |
| Numbers look wrong | Try clearing with Escape and re-entering the expression |

---

## Quitting the App

Close the window or press `Cmd+Q` to quit. To stop the terminal process, press `Ctrl+C` in Terminal.
