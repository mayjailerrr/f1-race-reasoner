%% =====================================================================
%% F1 Race Reasoner - Rules Legality Tests
%% =====================================================================

:- use_module('../data/base_scenario').
:- use_module('../src/facts').
:- use_module('../src/rules_legality').

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