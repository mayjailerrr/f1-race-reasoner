%% =====================================================================
%% F1 Race Reasoner - Rules Penalties Tests
%% =====================================================================

:- use_module('../src/rules_penalties').

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