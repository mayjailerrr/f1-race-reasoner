%% =====================================================================
%% F1 Race Reasoner - Penalty Assignment Rules
%% =====================================================================
%% This module maps illegal actions to specific penalties.
%% =====================================================================

:- module(rules_penalties, [
    penalty/3
]).

:- use_module('../src/rules_legality').

%% penalty(+Driver, +Lap, -PenaltyType) is semidet.
%
%  PenaltyType is the penalty assigned to Driver for the illegal action
%  committed on the given Lap.
%
%  Penalty mapping:
%    - Track limits       -> five_second_penalty
%    - Illegal overtake   -> drive_through
%    - Unsafe release     -> ten_second_penalty
%
penalty(Driver, Lap, five_second_penalty) :-
    exceeded_track_limits(Driver, Lap),
    !.
penalty(Driver, Lap, drive_through) :-
    illegal_overtake(Driver, _, Lap),
    !.
penalty(Driver, Lap, ten_second_penalty) :-
    unsafe_release(Driver, Lap),
    !.