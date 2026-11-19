# F1 RaceReasoner 🏎️

A declarative reasoning engine for Formula 1 race strategy and regulations, built with SWI-Prolog.

## Overview

**F1 RaceReasoner** is a logic-based system designed to model a subset of Formula 1 race scenarios. It allows users to query the legality of on-track actions, determine applicable penalties, and evaluate race strategies. 

Unlike imperative systems, this project focuses on the **"what"** rather than the **"how"**. It leverages Prolog's declarative nature, using facts, rules, and SLD resolution to deduce conclusions. Furthermore, it features a metaprogramming component that returns a **proof tree explanation** for every query, making the reasoning process completely transparent and traceable.

## Features

- **Race State Modeling:** Represent drivers, laps, tire compounds, stints, and race events (Safety Car, VSC, track limits).
- **Normative Reasoning:** Evaluate if an action is legal or subject to a penalty based on a simplified F1 rulebook.
- **Strategy Evaluation:** Generate and compare legal pit stop strategies based on time and tire degradation.
- **Explainable AI (XAI):** Instead of just returning `true` or `false`, the system generates a readable proof tree using a custom meta-interpreter.
- **Declarative Core:** Heavy use of logic programming concepts: recursion, lists, negation as failure, cut, and arithmetic.

## Tech Stack

- **Language:** [SWI-Prolog](https://www.swi-prolog.org/)
- **Paradigm:** Declarative Logic Programming

## Project Structure

```text
F1-RaceReasoner/
├── data/                # Prolog facts for synthetic race scenarios
├── demos/               # Executable demo scripts
├── docs/                # Project documentation (scope, data model, rules)
├── presentation/        # Slides and final report
├── src/                 # Core logic modules
│   ├── pretty_print.pl  # Formatting the explanation
│   └── main.pl          # Entry point
└── tests/               # Automated test suites
```

## Getting Started

### Prerequisites

You need SWI-Prolog installed on your system. 
- **Windows:** `winget install --id SWI-Prolog.SWI-Prolog -e`
- **macOS:** `brew install swi-prolog`
- **Linux:** `sudo apt-get install swi-prolog`

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/F1-RaceReasoner.git
   cd F1-RaceReasoner
   ```
2. Start SWI-Prolog and load the main file:
   ```bash
   swipl src/main.pl
   ```

## Usage 

Once inside the Prolog interactive shell, you can run queries. For example, to check if a driver's action is legal and get an explanation:

```bash
?- penalty(lap(32), driver(leclerc), pit_exit, Penalty).
```

To generate and explain a legal pit startegy: 

```bash
?- explain(legal_strategy(driver(verstappen), Strategy), Tree).
```

## Testing

The project uses SWI-Prolog's native `plunit` framework. To run the full test suite from the repository root:

```bash
swipl -g run_tests -t halt tests/run_tests.pl
```

## Documentation
For detailed information about the project scope, data models, and rules, please refer to the docs/ directory.

## License
This project is for academic purposes.