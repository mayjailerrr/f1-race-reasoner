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