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
test(illegal_overtake_under_sc, [nondet]) :-
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