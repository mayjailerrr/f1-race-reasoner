%% =====================================================================
%% F1 Race Reasoner - Facts Access Module
%% =====================================================================
%% This module provides the basic declarative access rules to query
%% the race state. It is intentionally kept simple: no complex
%% arithmetic, no penalty logic, no strategy generation.
%% =====================================================================

:- module(facts, [
    is_on_track/2,
    total_time/2,
    current_tyre/3,
    driver_team/2,
    lap_status/2,
    stint_of/3,
    event_at/3
]).

:- use_module(library(lists)).
:- use_module('../data/base_scenario').

%% is_on_track(+Driver, +Lap) is semidet.
%
%  Succeeds if Driver is on track at the given Lap.
%
is_on_track(Driver, Lap) :-
    driver(Driver, _),
    lap_time(Driver, Lap, _).

%% total_time(+Driver, -TotalTime) is det.
%
%  TotalTime is the sum of all lap times recorded for Driver.
%
total_time(Driver, TotalTime) :-
    driver(Driver, _),
    findall(Time, lap_time(Driver, _, Time), Times),
    sum_list(Times, TotalTime).

%% current_tyre(+Driver, +Lap, -Compound) is semidet.
%
%  Compound is the tyre compound that Driver is using at the given Lap.
%
current_tyre(Driver, Lap, Compound) :-
    stint(Driver, Compound, StartLap, EndLap),
    Lap >= StartLap,
    Lap =< EndLap.

%% driver_team(+Driver, -Team) is det.
%
driver_team(Driver, Team) :-
    driver(Driver, Team).

%% lap_status(+Lap, -Status) is det.
%
%  Status is the track status at the given Lap. Default: green.
%
lap_status(Lap, Status) :-
    (   track_status(Lap, Status)
    ->  true
    ;   Status = green
    ).

%% stint_of(+Driver, +Lap, -Compound) is semidet.
%
%  Alias for current_tyre/3, but with a more explicit name for
%  strategy-related queries.
%
stint_of(Driver, Lap, Compound) :-
    current_tyre(Driver, Lap, Compound).

%% event_at(+Lap, -EventType, -Driver) is nondet.
%
%  Yields each event type and the involved driver at the given Lap.
%
event_at(Lap, EventType, Driver) :-
    event(Lap, EventType, Driver, _).