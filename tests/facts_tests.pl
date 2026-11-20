%% =====================================================================
%% F1 Race Reasoner - Facts Tests
%% =====================================================================

:- use_module('../data/base_scenario').
:- use_module('../src/facts').

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