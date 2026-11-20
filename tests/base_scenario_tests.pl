%% =====================================================================
%% F1 Race Reasoner - Base Scenario Tests
%% =====================================================================

:- use_module('../data/base_scenario').

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