%% =====================================================================
%% F1 Race Reasoner - Test Suite Entry Point
%% =====================================================================
%% This file loads the scenario and the facts module, then runs the
%% plunit test boxes defined below.
%%
%% Usage:
%%   swipl -g run_tests -t halt tests/run_tests.pl
%% =====================================================================

:- use_module('../data/base_scenario').
:- use_module('../src/facts').
:- use_module('../src/rules_legality').
:- use_module('../src/rules_penalties').
:- use_module('../src/strategy').
:- use_module('../src/explanation').
:- use_module('../src/pretty_print').

%% ---------------------------------------------------------------------
%% Base Scenario Validation
%% ---------------------------------------------------------------------

:- begin_tests(base_scenario).

% Test 1: A known driver exists and is linked to a team.
test(driver_exists) :-
    driver(leclerc, ferrari).

% Test 2: A specific lap has a recorded time.
test(lap_has_time) :-
    lap_time(leclerc, 1, 90.5).

% Test 3: The Safety Car status is correctly recorded for a given lap.
test(safety_car_on_lap_7) :-
    track_status(7, sc).

% Test 4: Verify that a driver has a stint on a compound.
test(stint_exists) :-
    once(stint(leclerc, soft, 1, 5)).

:- end_tests(base_scenario).

%% ---------------------------------------------------------------------
%% Facts Module Validation
%% ---------------------------------------------------------------------

:- begin_tests(facts).

% Test 5: is_on_track/2 succeeds for a driver with a recorded lap.
test(is_on_track) :-
    is_on_track(leclerc, 6).

% Test 6: current_tyre/3 returns the expected compound for a lap.
test(current_tyre_hard) :-
    current_tyre(leclerc, 7, hard).

% Test 7: lap_status/2 defaults to green when no explicit status exists.
test(lap_status_default_green) :-
    lap_status(3, green).

:- end_tests(facts).

%% ---------------------------------------------------------------------
%% Rules Legality Module Validation
%% ---------------------------------------------------------------------

:- begin_tests(rules_legality).

% Track limits exceeded
% Test 8:
test(track_limits_exceeded) :-
    exceeded_track_limits(leclerc, 3).

% Test 9:
test(track_limits_clean) :-
    \+ exceeded_track_limits(verstappen, 3).

% Unsafe release
% Test 10:
test(unsafe_release_sainz) :-
    unsafe_release(sainz, 6).

% Test 11:
test(unsafe_release_hamilton_fails) :-
    \+ unsafe_release(hamilton, 6).

% Illegal overtake
% Test 12: 
test(illegal_overtake_under_sc) :-
    illegal_overtake(hamilton, piastri, 7).

% Test 13:
test(legal_overtake_under_green) :-
    \+ illegal_overtake(verstappen, leclerc, 12).

% Allowed overtake
% Test 14: 
test(allowed_under_green) :-
    allowed_overtake(verstappen, leclerc, 12).

% Test 15: 
test(not_allowed_under_sc) :-
    \+ allowed_overtake(hamilton, piastri, 7).

% Overall legality check
% Test 16:
test(illegal_action_track_limits, [nondet]) :-
    illegal_action(leclerc, 3, track_limits).

% Test 17:
test(illegal_action_unsafe_release, [nondet]) :-
    illegal_action(sainz, 6, unsafe_release).

% Test 18:
test(illegal_action_illegal_overtake, [nondet]) :-
    illegal_action(hamilton, 7, illegal_overtake(piastri)).

% Test 19:
test(fully_legal_lap_clean) :-
    fully_legal_lap(verstappen, 1).

% Test 20:
test(fully_legal_lap_with_track_limits) :-
    \+ fully_legal_lap(leclerc, 3).

% Test 21:
test(fully_legal_lap_with_unsafe_release) :-
    \+ fully_legal_lap(sainz, 6).

:- end_tests(rules_legality).

%% ---------------------------------------------------------------------
%% Rules Penalties Module Validation
%% ---------------------------------------------------------------------

:- begin_tests(rules_penalties).

% Test 22: Track limits violation maps to a 5-second penalty.
test(penalty_track_limits) :-
    penalty(leclerc, 3, five_second_penalty).

% Test 23: Illegal overtake under SC maps to a drive-through penalty.
test(penalty_illegal_overtake) :-
    penalty(hamilton, 7, drive_through).

% Test 24: Unsafe release maps to a 10-second penalty.
test(penalty_unsafe_release) :-
    penalty(sainz, 6, ten_second_penalty).

% Test 25: A clean lap receives no penalty (negative test).
test(no_penalty_for_clean_lap) :-
    \+ penalty(verstappen, 1, _).

% Test 26: penalty/3 is deterministic thanks to the cut.
test(penalty_is_deterministic) :-
    once(penalty(leclerc, 3, P)),
    P == five_second_penalty.

:- end_tests(rules_penalties).

%% ---------------------------------------------------------------------
%% Strategy Module Validation
%% ---------------------------------------------------------------------

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

%% ---------------------------------------------------------------------
%% Explanation Module Validation
%% ---------------------------------------------------------------------

:- begin_tests(explanation).

% Test 48: solve/2 produces a fact proof.
test(solve_fact, [nondet]) :-
    solve(driver(leclerc, ferrari),
          proof(driver(leclerc, ferrari), fact)).

% Test 49: solve/2 produces a rule proof with a nested body.
test(solve_rule) :-
    solve(exceeded_track_limits(leclerc, 3),
          proof(exceeded_track_limits(leclerc, 3), rule(_))).

% Test 50: solve/2 handles negation as failure.
test(solve_negation) :-
    solve(is_legal_lap(leclerc, 32),
          proof(is_legal_lap(leclerc, 32),
                rule(proof(\+ exceeded_track_limits(leclerc, 32),
                            not_provable(exceeded_track_limits(leclerc, 32)))))).

% Test 51: solve/2 fails for an unprovable goal.
test(solve_unprovable) :-
    \+ solve(exceeded_track_limits(leclerc, 32), _).

% Test 52: solve/3 respects the depth budget.
test(solve_depth_exhausted) :-
    \+ solve(is_legal_lap(leclerc, 32), _, 1).

:- end_tests(explanation).

:- begin_tests(explain).

% Test 53: explain/2 succeeds on a penalty rule and returns a tree.
test(explain_penalty_success, [nondet]) :-
    with_output_to(string(_), explain(penalty(leclerc, 3, P), E)),
    P == five_second_penalty,
    E = proof(_, _).

% Test 54: explain/2 on an unprovable goal returns no_proof/1.
test(explain_no_proof, [nondet]) :-
    with_output_to(string(Out), explain(penalty(leclerc, 32, _), E)),
    E = no_proof(_),
    sub_string(Out, _, _, _, "No proof found").

% Test 55: explain/2 works for legality rules.
test(explain_illegal_overtake, [nondet]) :-
    with_output_to(string(_),
                   explain(illegal_overtake(hamilton, piastri, 7), E)),
    E = proof(_, _).

% Test 56: explain/2 works for strategy rules.
test(explain_legal_strategy, [nondet]) :-
    with_output_to(string(_),
                   explain(legal_strategy(leclerc, [soft, hard]), E)),
    E = proof(_, _).

:- end_tests(explain).

%% ---------------------------------------------------------------------
%% Pretty Print Module Validation
%% ---------------------------------------------------------------------

:- begin_tests(pretty_print).

test(pretty_print_fact, [nondet]) :-
    solve(driver(leclerc, ferrari), Tree),
    with_output_to(string(_), pretty_print(Tree)).

test(pretty_print_rule_negation, [nondet]) :-
    solve(is_legal_lap(leclerc, 32), Tree),
    with_output_to(string(_), pretty_print(Tree)).

test(pretty_print_conjunction, [nondet]) :-
    solve((driver(leclerc, ferrari), team(ferrari)), Tree),
    with_output_to(string(_), pretty_print(Tree)).

test(pretty_print_with_indent, [nondet]) :-
    solve(driver(leclerc, ferrari), Tree),
    with_output_to(string(_), pretty_print(Tree, 2)).

:- end_tests(pretty_print).

%% ---------------------------------------------------------------------
%% Meta-Iterpreter General Validation
%% ---------------------------------------------------------------------

:- begin_tests(metainterpreter_robustness).

% R1: solve/2 returns a compound term, never a raw atom.
test(solve_returns_compound, [nondet]) :-
    solve(driver(leclerc, ferrari), Tree),
    compound(Tree),
    Tree = proof(_, _).

% R2: solve/2 on a conjunction returns conj/2 inside proof/2.
test(solve_returns_conj_term) :-
    solve((driver(leclerc, ferrari), team(ferrari)), Tree),
    Tree = proof(_, conj(_, _)).

% R3: solve/3 with depth 0 fails cleanly (no crash, no exception).
test(solve_depth_zero_fails_cleanly) :-
    \+ solve(driver(leclerc, ferrari), _, 0).

% R4: solve/2 handles a built-in predicate without throwing.
test(solve_builtin_goal, [nondet]) :-
    solve(atom(leclerc), Tree),
    Tree = proof(atom(leclerc), builtin).

% R5: explain/2 on a complex nested rule (penalty → illegal_overtake
%     → event + lap_status) produces a rule tree without crashing.
test(explain_complex_nested_rule, [nondet]) :-
    with_output_to(string(_),
                   explain(penalty(hamilton, 7, drive_through), E)),
    E = proof(_, rule(_)).

% R6: explain/2 on a conjunction returns a conj tree.
test(explain_conjunction, [nondet]) :-
    with_output_to(string(_),
                   explain((driver(leclerc, ferrari), team(ferrari)), E)),
    E = proof(_, conj(_, _)).

% R7: explain/2 on a rule whose body contains NAF in the chain
%     (fully_legal_lap → \+ illegal_action).
test(explain_rule_with_naf, [nondet]) :-
    with_output_to(string(_),
                   explain(fully_legal_lap(verstappen, 1), E)),
    E = proof(_, rule(_)).

% R8: explain/2 on a well-defined but failing goal returns no_proof/1
%     and does not crash.
test(explain_no_proof_well_defined) :-
    once(( with_output_to(string(Out),
                          explain(exceeded_track_limits(leclerc, 32), E)),
           E = no_proof(_),
           sub_string(Out, _, _, _, "No proof found")
         )).

:- end_tests(metainterpreter_robustness).