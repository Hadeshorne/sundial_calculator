# Sundial Calculator — User Manual

## What is Sundial Calculator?

Sundial Calculator is a calculator app for your Mac that does something most calculators don't — it shows you a picture of your answer alongside the number. This helps you quickly confirm that a result "looks right" before you use it.

---

## Setting Up for the First Time

### What You Need
- A Mac running macOS 14 (Sonoma) or newer
- A one-time install of Apple's developer tools (instructions below)

### Step 1: Install Apple's Developer Tools

You only need to do this once. If you've done it before, skip to Step 2.

1. Open the **Terminal** app. To find it: click the magnifying glass (Spotlight) in the top-right corner of your screen, type **Terminal**, and press Return.
2. A window with a blinking cursor will appear. Type the following exactly as shown and press Return:

       xcode-select --install

3. A pop-up will appear asking you to install the tools. Click **Install** and wait for it to finish. This may take a few minutes.

### Step 2: Build the App

Each time after downloading or updating the app, you need to build it once.

1. Open **Terminal** (same as above).
2. Type the following and press Return (replace the path with wherever you saved the Sundial_Calculator folder):

       cd /path/to/Sundial_Calculator

   For example, if you saved it in your Downloads folder, you would type:

       cd ~/Downloads/Sundial_Calculator

3. Type the following and press Return:

       swift build

4. Wait until you see the words **Build complete!** appear. This may take a minute or two the first time.

### Step 3: Launch the App

With Terminal still open from the previous step, type the following and press Return:

    swift run

A calculator window will appear on your screen. You're ready to go!

**Tip:** Each time you want to use the calculator, you only need to repeat Step 3. You don't need to rebuild unless you've updated the app.

---

## The Calculator Window

When the app opens, you'll see three areas:

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

1. **History Sidebar** (left side) — a list of your past calculations
2. **Display** (top right) — shows what you're typing and the answer
3. **Visual Answer Panel** (middle right) — a picture of your answer
4. **Keypad** (bottom right) — buttons for numbers and operations, just like a physical calculator

---

## How to Use It

### Typing a Calculation

**Using your keyboard (the fastest way):**

Just type your math problem. For example, type **5+3** and then press the **Return** key (also labeled Enter on some keyboards). The answer **8** will appear.

**Using the mouse:**

Click the number and operator buttons on the keypad, then click the **=** button.

### Available Operations

| What you want to do | What to type on your keyboard | What to click on the keypad |
|---|---|---|
| Add | **+** | + |
| Subtract | **-** | − |
| Multiply | ***** (the asterisk key) | × |
| Divide | **/** (the forward slash key) | ÷ |
| Power (e.g., 5 squared) | **^** (Shift+6 on most keyboards) | ^ |
| Square root | — (use the keypad button) | √ |
| Get the answer | **Return** (or Enter) | = |
| Decimal point | **.** (period) | . |
| Percent | **%** (Shift+5 on most keyboards) | % |
| Parentheses | **(** and **)** | ( and ) |

### Examples

| What to type | Then press | Answer | What it means |
|---|---|---|---|
| 12+8 | Return | 20 | Twelve plus eight |
| 100/4 | Return | 25 | One hundred divided by four |
| (10+5)*3 | Return | 45 | Ten plus five, then multiply by three |
| 200+10% | Return | 220 | Two hundred plus 10% of 200 |
| 50% | Return | 0.5 | Fifty percent as a decimal |
| 5^2 | Return | 25 | Five squared (5 times 5) |
| 1.05^10 | Return | ≈1.629 | Compound interest factor |
| Click √, then type 144 | Return | 12 | The square root of 144 |

---

## Fixing Mistakes

| What you want to do | On your keyboard | On the keypad |
|---|---|---|
| Delete the last character you typed | **Delete** key | ⌫ button |
| Start over (clear everything) | **Escape** key | **C** button |
| Switch between positive and negative | — | **±** button |

If you see an error message, just start typing a new number or press Escape — the error will clear automatically.

---

## The Visual Answer Panel

After every calculation, a picture of your answer appears below the result. This is the feature that makes Sundial Calculator different from ordinary calculators — it gives you a quick visual check.

### Six Types of Pictures

You can switch between six views by clicking the selector above the picture:

1. **Number Line** — Places your numbers as dots on a line with an arc showing the operation. Best for addition and subtraction — you can see the "jump" between numbers.

2. **Place Value** — Breaks your answer into thousands, hundreds, tens, and ones using color-coded blocks. Helpful for understanding large numbers at a glance.

3. **Proportion** — Shows your numbers as colored bars next to each other. Helpful for seeing how big one number is compared to another.

4. **Magnitude** — A logarithmic scale showing where your numbers fall across orders of magnitude (1, 10, 100, 1K, etc.). Helpful for understanding very large or very small numbers and seeing how far apart two numbers are on a grand scale.

5. **Factor** — Shows operands as side-by-side bars with a ratio annotation. For addition and subtraction, highlights the change amount and percentage. Helpful for seeing how numbers relate to each other proportionally.

6. **Area** — Displays multiplication, division, and power results as a grid of cells where columns and rows represent the operands. Helpful for visualizing what "5 times 8" actually looks like as an area.

### Hiding the Visual Panel

If you prefer a plain calculator, click the chart icon in the toolbar to hide the pictures. Click it again to bring them back.

---

## History

Every calculation you perform is saved in the sidebar on the left.

- The most recent calculation appears at the top.
- Click any past calculation to bring it back into the display.
- Click **Clear** at the top of the history list to erase all history.

### Hiding the History Sidebar

Click the sidebar icon in the toolbar to show or hide the history panel.

---

## Memory Functions

Memory lets you save a number and use it later — handy for running totals or multi-step calculations.

| Button | What it does |
|---|---|
| **M+** | Adds the current answer to memory |
| **M−** | Subtracts the current answer from memory |
| **MR** | Inserts the saved memory value into your current calculation |
| **MC** | Erases the memory |

When memory has a value stored, you'll see **M: (value)** below the result.

**Example: Adding up several calculations**

1. Type **100*3** and press Return → answer is 300
2. Click **M+** (memory now holds 300)
3. Type **50*4** and press Return → answer is 200
4. Click **M+** (memory now holds 500)
5. Click **C** to clear, then click **MR** → 500 appears, ready to use

---

## Handy Keyboard Shortcuts

Beyond the basic typing shortcuts above, the app supports these combinations:

| Keys to press | What happens |
|---|---|
| **Cmd+C** | Copies the answer so you can paste it into other apps |
| **Cmd+Shift+E** | Copies the current expression (what you've typed so far) |
| **Cmd+V** | Pastes text from your clipboard into the expression |
| **Cmd+Shift+C** | Clears the current calculation |
| **Cmd+Shift+A** | Clears everything — calculation, history, and memory |
| **Cmd+Shift+V** | Shows or hides the visual answer panel |

(The **Cmd** key is the one with the ⌘ symbol, next to the spacebar.)

---

## Menu Bar

The app adds two menus to your Mac's menu bar at the top of the screen:

**Calculator menu:**
- Clear, All Clear
- Copy Result, Copy Expression, Paste
- Toggle Visual Answer

**Memory menu:**
- Memory Add, Subtract, Recall, Clear

---

## Tips for Getting the Most Out of Sundial

- **Keep calculating from a result:** After getting an answer, press an operator key (+, −, etc.) to keep going from that number. No need to retype it.
- **Use parentheses to control order:** The calculator follows standard math rules. **10+5*3** gives 25 (multiplication first), but **(10+5)*3** gives 45 (addition first, then multiply).
- **Exponents with ^:** Type **2^10** to get 1024. Great for compound interest — **1000*1.05^10** shows what $1,000 becomes at 5% annual growth over 10 years.
- **Square root with √:** Click the √ button, type a number, and press Return. Note: the square root of a negative number will show an error.
- **Percentage shortcut:** Type **200+10%** and the calculator automatically figures out "200 plus 10% of 200" = 220. Works with subtraction too: **200-10%** = 180.
- **Copy and paste:** Press **Cmd+C** to copy your answer, or **Cmd+Shift+E** to copy the expression. Press **Cmd+V** to paste a number or expression from another app into the calculator.
- **Visual sanity check:** If a result seems off, look at the visual panel. A number line or proportion bar can instantly reveal if something is way too big or too small.

---

## Troubleshooting

| What you see | What to do |
|---|---|
| No window appears after launching | Go back to Step 2 (Build the App) and make sure you saw "Build complete!" before launching |
| "Cannot divide by zero" | You tried to divide by zero. Change the number you're dividing by. |
| "Undefined result" | You tried something mathematically impossible, like the square root of a negative number. |
| "Invalid expression" | Check that your calculation doesn't have misplaced symbols (for example, two operators in a row like **++**). |
| "Mismatched parentheses" | Every opening parenthesis **(** needs a closing one **)**. Count them to make sure they match. |
| The app won't build | Go back to Step 1 and make sure Apple's developer tools are installed. |
| Numbers look wrong | Press Escape to clear and type the calculation again from scratch. |

---

## Quitting the App

- Close the window, or press **Cmd+Q** to quit.
- If Terminal is still open, you can also press **Control+C** in the Terminal window to stop the app.
