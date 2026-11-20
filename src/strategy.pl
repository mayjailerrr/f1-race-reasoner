%% =====================================================================
%% F1 Race Reasoner - Strategy Module
%% =====================================================================
%% This module contains the logic to evaluate pit stop strategies. It
%% relies on the tire compound pace facts and the stint history to
%% compute tire age and generate legal strategies.
%% =====================================================================

:- module(strategy, [
    max_stints/1,
    tire_age/3,
    legal_strategy/2,
    strategy_time/3,
    best_strategy/3
]).

:- use_module('../data/base_scenario').
:- use_module('../src/facts').

%% max_stints(-Max) is det.
%
%  Max is the maximum number of stints a legal strategy may contain.
%  Bounds the search space of legal_strategy/2 to avoid infinite
%  generation. A dry F1 race typically has 2-4 stints (1-3 pit stops).
%
max_stints(3).

%% tire_age(+Driver, +Lap, -Age) is semidet.
%
%  Age is the number of laps Driver has completed on the current tire
%  at the given Lap (1 = first lap on a fresh set).
%
%  Fails if Driver has no stint covering the given Lap.
%
tire_age(Driver, Lap, Age) :-
    stint(Driver, _Compound, StartLap, EndLap),
    Lap >= StartLap,
    Lap =< EndLap,
    Age is Lap - StartLap + 1.

%% legal_strategy(+Driver, -Strategy) is nondet.
%
%  Strategy is a list of tire compounds (e.g. [soft, hard]) that respects
%  the simplified FIA dry-race rule: at least two different compounds
%  must be used. Uses recursion to build the list and Negation as
%  Failure to reject strategies that only use a single compound.
%
legal_strategy(Driver, Strategy) :-
    driver(Driver, _),
    max_stints(Max),
    between(2, Max, NumStints),
    length(Strategy, NumStints),
    generate_stints(Strategy),
    \+ all_same_compound(Strategy).

%% generate_stints(-Strategy) is nondet.
%
%  Recursively builds a list of compounds, each of which must exist in
%  compound_pace/3. Base case: the empty list. Recursive case: pick a
%  valid compound, then build the rest.
%
generate_stints([]).
generate_stints([Compound|Rest]) :-
    compound_pace(Compound, _, _),
    generate_stints(Rest).

%% all_same_compound(+Strategy) is semidet.
%
%  Succeeds if every element of Strategy is the same compound. Used via
%  Negation as Failure to reject strategies that violate the FIA rule.
%  Assumes Strategy is a non-empty list.
%
all_same_compound([Compound|Rest]) :-
    all_same(Compound, Rest).

all_same(_, []).
all_same(Compound, [Compound|Rest]) :-
    all_same(Compound, Rest).

%% race_laps(-TotalLaps) is det.
%
%  TotalLaps is the total number of laps in the race (from base_scenario).
%
race_laps(15).

%% pit_stop_loss(-Seconds) is det.
%
%  Seconds is the fixed time penalty added to a strategy per pit stop
%  (pit-lane transit relative to staying on track). 25s is realistic
%  for a modern F1 pit lane.
%
pit_stop_loss(25).

%% strategy_time(+Strategy, +PitStops, -TotalTime) is semidet.
%
%  TotalTime is the total race time, in seconds, of running Strategy
%  with the given number of pit stops.
%  Strategy and PitStops must be consistent: PitStops =:= length(Strategy) - 1.
%
%  The total race is divided as evenly as possible among the stints
%  (earlier stints get the extra lap when the division is not exact).
%  Each stint's time is the sum of the per-lap pace of its compound
%  including degradation. Pit stops add pit_stop_loss/1 seconds each.
%
%  Fails if PitStops is inconsistent with the length of Strategy.
%
%  @param Strategy  List of compounds (e.g. [soft, hard]).
%  @param PitStops  Number of pit stops (integer).
%  @param TotalTime Total race time in seconds (float).
%
strategy_time(Strategy, PitStops, TotalTime) :-
    length(Strategy, NumStints),
    NumStints > 0,
    PitStops =:= NumStints - 1,
    race_laps(TotalLaps),
    BaseLaps is TotalLaps // NumStints,
    ExtraLaps is TotalLaps mod NumStints,
    stints_time(Strategy, BaseLaps, ExtraLaps, StintsTime),
    pit_stop_loss(Loss),
    TotalTime is StintsTime + PitStops * Loss.

%% stints_time(+Strategy, +BaseLaps, +ExtraLaps, -Total) is det.
%
%  Recursively sums the time of every stint. The first ExtraLaps stints
%  receive one additional lap each so the total equals race_laps/1.
%
stints_time([], _, _, 0).
stints_time([Compound|Rest], BaseLaps, ExtraLaps, Total) :-
    (   ExtraLaps > 0
    ->  Laps is BaseLaps + 1,
        RemainingExtra is ExtraLaps - 1
    ;   Laps = BaseLaps,
        RemainingExtra = 0
    ),
    stint_time(Compound, Laps, StintTime),
    stints_time(Rest, BaseLaps, RemainingExtra, RestTime),
    Total is StintTime + RestTime.

%% stint_time(+Compound, +Laps, -Time) is det.
%
%  Time is the sum of the per-lap pace of Compound over Laps laps,
%  including degradation: sum_{i=0}^{Laps-1} (Base + Deg*i).
%  Closed form: Laps*Base + Deg*Laps*(Laps-1)/2.
%
stint_time(Compound, Laps, Time) :-
    compound_pace(Compound, Base, Deg),
    Time is Laps * Base + Deg * (Laps * (Laps - 1) / 2).

%% best_strategy(+Driver, -BestStrategy, -BestTime) is semidet.
%
%  BestStrategy is the legal strategy for Driver that minimises total
%  race time. BestTime is its total time in seconds.
%
%  Fails if Driver has no legal strategies.
%
best_strategy(Driver, BestStrategy, BestTime) :-
    findall(Time-Strat,
            strategy_candidate(Driver, Time, Strat),
            Pairs),
    Pairs \= [],
    sort(Pairs, [BestTime-BestStrategy|_]).

%% strategy_candidate(+Driver, -Time, -Strategy) is nondet.
%
%  Helper for best_strategy/3. Yields each legal strategy for Driver
%  together with its total race time. PitStops is derived from the
%  strategy length, so it is always consistent with strategy_time/3.
%
strategy_candidate(Driver, Time, Strategy) :-
    legal_strategy(Driver, Strategy),
    length(Strategy, NumStints),
    PitStops is NumStints - 1,
    strategy_time(Strategy, PitStops, Time).