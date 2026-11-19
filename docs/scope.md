# Project Scope: F1 RaceReasoner

## 1. Project Overview
**F1 RaceReasoner** is a declarative reasoning engine built with SWI-Prolog. The system models a simplified subset of Formula 1 race scenarios to evaluate the legality of on-track actions, assign penalties, and determine optimal pit stop strategies. Furthermore, it provides a readable proof tree for every query using a custom meta-interpreter.

## 2. Minimum Viable Product (MVP)
The project will be considered **complete and functional** (MVP achieved) when the following end-to-end workflow is fully operational:

1. **Data Loading:** The system loads a synthetic race scenario (drivers, laps, events, tire compounds).
2. **Normative Reasoning:** The system can evaluate queries regarding track limits, overtaking under Safety Car/VSC, and pit exit safety, returning the applicable penalty.
3. **Strategy Evaluation:** The system can generate legal pit stop strategies (using lists and recursion) and calculate the best strategy based on race time (using arithmetic and `findall/3`).
4. **Explainability (XAI):** The system returns a structured, readable proof tree explaining *why* a specific penalty was assigned or *why* a strategy is optimal.
5. **Validation:** The repository includes an automated test suite (`plunit`) and a reproducible CLI demo script.

## 3. Out of Scope (Explicitly NOT included)
To ensure a high-quality, focused deliverable, the following features are explicitly **out of scope** and will not be implemented:
- **Full FIA Regulations:** The system uses a simplified, synthetic subset of F1 rules (e.g., a basic track limits rule, a basic SC overtaking rule). It is not a legal simulator.
- **Real-time Data Integration:** The system will not connect to live timing APIs or real telemetry feeds. Data will be static Prolog facts.
- **Graphical User Interface (GUI):** The interaction will be strictly CLI-based (Command Line Interface) using the SWI-Prolog interactive shell.
- **Probabilistic Reasoning:** The system uses deterministic logic. It will not calculate probabilities of rain or the likelihood of a mechanical failure.

## 4. Declarative Coverage (Academic Requirements)
This project explicitly demonstrates the following declarative programming concepts covered in the course:

| Concept | Implementation in F1 RaceReasoner |
| :--- | :--- |
| **Facts and Rules** | `data/base_scenario.pl`, `src/rules_legality.pl` |
| **Lists and Recursion** | Generation of pit stop strategies in `src/strategy.pl` |
| **SLD Resolution** | Core Prolog execution and traceable via `src/explanation.pl` |
| **Negation as Failure** | Used for defining legal actions (`\+ illegal_action`) |
| **Cut (`!`)** | Used in penalty assignment to ensure determinism |
| **Arithmetic** | Calculation of race times, tire degradation, and pit stop loss |
| **Deductive Databases** | The race state is modeled as a deductive database |
| **Metaprogramming** | A custom meta-interpreter (`solve/2`) to build proof trees |

## 5. Definition of Done (General)
For the project to be submitted, the following criteria must be met:
- The code loads without errors or warnings in SWI-Prolog.
- The automated test suite runs successfully (`All tests passed`).
- The `README.md` provides clear instructions on how to run the demo.
- The final report and presentation slides are completed.