%% =====================================================================
%% F1 Race Reasoner - Legality Rules
%% =====================================================================
%% This module contains the rules to determine the legality of
%% on-track actions based on the race events.
%% =====================================================================

:- module(rules_legality, [
    exceeded_track_limits/2,
    is_legal_lap/2,
    unsafe_release/2,
    illegal_overtake/3,
    allowed_overtake/3,
    illegal_action/3,
    fully_legal_lap/2
]).

:- use_module('../data/base_scenario').
:- use_module('../src/facts').

%% exceeded_track_limits(+Driver, +Lap) is semidet.
%
%  Succeeds if Driver exceeded track limits on the given Lap.
%
exceeded_track_limits(Driver, Lap) :-
    event(Lap, track_limits, Driver, _).

%% is_legal_lap(+Driver, +Lap) is semidet.
%
%  Succeeds if Driver did NOT exceed track limits on the given Lap.
%
is_legal_lap(Driver, Lap) :-
    \+ exceeded_track_limits(Driver, Lap).

%% unsafe_release(+Driver, +Lap) is semidet.
%
%  Succeeds if Driver was involved in an unsafe release from the pit lane
%  on the given Lap. The event's Details field describes the driver who
%  was in the path, e.g. released_into(hamilton).
%
unsafe_release(Driver, Lap) :-
    event(Lap, unsafe_release, Driver, _).

%% illegal_overtake(+Driver, +OvertakenDriver, +Lap) is semidet.
%
%  Succeeds if Driver illegally overtook OvertakenDriver on the given Lap.
%  An overtake is illegal if it occurred under Safety Car (sc) or
%  Virtual Safety Car (vsc).
%
illegal_overtake(Driver, OvertakenDriver, Lap) :-
    event(Lap, overtake, Driver, overtook(OvertakenDriver)),
    lap_status(Lap, Status),
    ( Status == sc ; Status == vsc ).

%% allowed_overtake(+Driver, +OvertakenDriver, +Lap) is semidet.
%
%  Succeeds if the overtake is NOT illegal.
%
allowed_overtake(Driver, OvertakenDriver, Lap) :-
    \+ illegal_overtake(Driver, OvertakenDriver, Lap).

%% illegal_action(+Driver, +Lap, -Reason) is nondet.
%
%  Overall legality check. Yields each illegal action committed by Driver
%  on the given Lap, along with a descriptive Reason.
%
illegal_action(Driver, Lap, track_limits) :-
    exceeded_track_limits(Driver, Lap).
illegal_action(Driver, Lap, unsafe_release) :-
    unsafe_release(Driver, Lap).
illegal_action(Driver, Lap, illegal_overtake(Overtaken)) :-
    illegal_overtake(Driver, Overtaken, Lap).

%% fully_legal_lap(+Driver, +Lap) is semidet.
%
%  Succeeds if Driver committed no illegal actions on the given Lap.
%
fully_legal_lap(Driver, Lap) :-
    \+ illegal_action(Driver, Lap, _).