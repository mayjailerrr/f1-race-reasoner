# Data Model: F1 RaceReasoner

## 1. Introduction
This document defines the core entities (predicates) and their arguments (arity) that will be used to model the Formula 1 race scenario. The model is designed to be declarative, simple, and optimized for rule evaluation and recursion. 

All entities will be represented as Prolog facts in the `data/base_scenario.pl` file.

## 2. Core Entities

### 2.1 Teams and Drivers
Used to define the static participants of the race.

*   `team(TeamName)` 
    *   `TeamName`: Atom (e.g., `ferrari`, `red_bull`).
*   `driver(DriverName, TeamName)`
    *   `DriverName`: Atom (e.g., `leclerc`, `verstappen`).
    *   `TeamName`: Atom (must match a `team/1` fact).

### 2.2 Race State & Lap Times
Used to define the timeline of the race.

*   `track_status(Lap, Status)`
    *   `Lap`: Integer (1 to N).
    *   `Status`: Atom (`green`, `sc`, `vsc`). 
    *   *Note:* If a lap is not explicitly defined, it is assumed to be `green`.
*   `lap_time(Driver, Lap, TimeSeconds)`
    *   `Driver`: Atom.
    *   `Lap`: Integer.
    *   `TimeSeconds`: Number (e.g., `92.5`).

### 2.3 Tires and Stints
Used for the strategy evaluation.

*   `compound_pace(Compound, BaseTime, DegradationPerLap)`
    *   `Compound`: Atom (`soft`, `medium`, `hard`).
    *   `BaseTime`: Number (Base lap time in seconds).
    *   `DegradationPerLap`: Number (Time lost per lap due to tire wear).
*   `stint(Driver, Compound, StartLap, EndLap)`
    *   `Driver`: Atom.
    *   `Compound`: Atom.
    *   `StartLap`: Integer.
    *   `EndLap`: Integer.
    *   *Note:* Represents the exact tire history of a driver.

### 2.4 Events & Incidents
Used to evaluate legality and penalties.

*   `event(Lap, EventType, Driver, Details)`
    *   `Lap`: Integer.
    *   `EventType`: Atom (`track_limits`, `overtake`, `unsafe_release`, `collision`).
    *   `Driver`: Atom (The driver who caused or is involved in the event).
    *   `Details`: Atom or Compound term (e.g., `turn_4`, `overtook(hamilton)`, `released_into(sainz)`).
*   `pit_stop(Driver, Lap, DurationSeconds)`
    *   `Driver`: Atom.
    *   `Lap`: Integer.
    *   `DurationSeconds`: Number (Time spent in the pit lane, e.g., `25.0`).

## 3. Example Data (How it will look in Prolog)

```prolog
% Teams and Drivers
team(ferrari).
team(red_bull).
driver(leclerc, ferrari).
driver(verstappen, red_bull).

% Lap Times (only a small excerpt)
lap_time(leclerc, 1, 95.2).
lap_time(verstappen, 1, 95.0).

% Track Status (Laps 10-12 are Safety Car)
track_status(10, sc).
track_status(11, sc).
track_status(12, sc).

% Tires
compound_pace(soft, 92.0, 0.8).
compound_pace(hard, 94.0, 0.3).

% Stints (Leclerc starts on soft, pits on lap 15 for hard)
stint(leclerc, soft, 1, 14).
stint(leclerc, hard, 15, 50).

% Events (An illegal overtake during a Safety Car)
event(11, overtake, leclerc, overtook(verstappen)).