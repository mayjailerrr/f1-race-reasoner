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
