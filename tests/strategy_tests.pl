%% =====================================================================
%% F1 Race Reasoner - Strategy Tests
%% =====================================================================

:- use_module('../data/base_scenario').
:- use_module('../src/strategy').

:- begin_tests(strategy).

% Tire compound and age
% Test 27: Compound pace data is correctly loaded from base_scenario.
test(compound_pace_soft) :-
    compound_pace(soft, 90.0, 0.8).

% Test 28: First lap on a fresh tire has age 1 (Leclerc's hard on lap 6).
test(tire_age_first_lap) :-
    tire_age(leclerc, 6, 1).

% Test 29: Mid-stint tire age is computed correctly (Leclerc on lap 10).
test(tire_age_mid_stint) :-
    tire_age(leclerc, 10, 5).

% Test 30: Verstappen's first lap on medium.
test(tire_age_verstappen_lap_1, [nondet]) :-
    tire_age(verstappen, 1, 1).

% Test 30.1: Verstappen's last lap on soft (stint 11-15, so lap 15 = age 5).
test(tire_age_verstappen_last_lap) :-
    tire_age(verstappen, 15, 5).

% Test 31: Negative test - a lap outside any stint fails.
test(tire_age_outside_stint_fails) :-
    \+ tire_age(leclerc, 20, _).

% Legal strategy generation
% Test 32: Two different compounds form a legal strategy.
test(legal_two_compounds) :-
    once(legal_strategy(leclerc, [soft, hard])).

% Test 33: Three mixed compounds form a legal strategy.
test(legal_three_mixed) :-
    once(legal_strategy(leclerc, [soft, hard, medium])).

% Test 34: Same compound twice violates the FIA rule (NAF).
test(illegal_all_same_two) :-
    \+ legal_strategy(leclerc, [soft, soft]).

% Test 35: Same compound three times violates the FIA rule (NAF).
test(illegal_all_same_three) :-
    \+ legal_strategy(leclerc, [medium, medium, medium]).

% Test 36: A single stint violates the FIA rule.
test(illegal_single_stint) :-
    \+ legal_strategy(leclerc, [hard]).

% Test 37: Four stints exceed max_stints(3).
test(illegal_four_stints_exceeds_max) :-
    \+ legal_strategy(leclerc, [soft, hard, soft, hard]).

% Test 38: Enumeration - exactly 30 legal strategies (36 total - 6 all-same).
test(count_legal_strategies) :-
    findall(S, legal_strategy(leclerc, S), All),
    length(All, N),
    N =:= 30.

% Strategy time calculation
% Test 39: [soft, hard] with 1 pit stop calculates the expected time.
test(strategy_time_soft_hard) :-
    strategy_time([soft, hard], 1, T),
    abs(T - 1419.1) < 0.01.

% Test 40: [hard, soft] with 1 pit stop is faster than [soft, hard]
%          because the faster compound is used at the end of the race.
test(strategy_time_hard_soft_faster) :-
    strategy_time([soft, hard], 1, T1),
    strategy_time([hard, soft], 1, T2),
    T2 < T1.

% Test 41: Three-stint strategy with 2 pit stops calculates the time.
test(strategy_time_three_stints) :-
    strategy_time([hard, soft, medium], 2, T),
    abs(T - 1434.0) < 0.01.

% Test 42: A single stint (0 pit stops) is a valid input for the time calc.
test(strategy_time_single_stint) :-
    strategy_time([soft], 0, T),
    abs(T - 1434.0) < 0.01.

% Test 43: Negative - PitStops argument inconsistent with Strategy length fails.
test(strategy_time_pitstops_mismatch_fails) :-
    \+ strategy_time([soft, hard], 2, _).

% Test 44: TotalTime is always a number greater than zero.
test(strategy_time_returns_number) :-
    strategy_time([medium, hard], 1, T),
    number(T),
    T > 0.

% Optimal strategy generation
% Test 45: best_strategy/3 returns a numeric positive time.
test(best_strategy_returns_number) :-
    best_strategy(verstappen, _, T),
    number(T),
    T > 0.

% Test 46: best_strategy/3 returns the minimum over all legal strategies.
test(best_strategy_is_minimum) :-
    findall(T,
            ( legal_strategy(verstappen, S),
              length(S, N),
              P is N - 1,
              strategy_time(S, P, T) ),
            All),
    min_list(All, Min),
    best_strategy(verstappen, _, BestT),
    abs(BestT - Min) < 0.01.

% Test 47: the returned strategy is itself legal.
test(best_strategy_is_legal, [nondet]) :-
    best_strategy(verstappen, S, _),
    legal_strategy(verstappen, S).

:- end_tests(strategy).