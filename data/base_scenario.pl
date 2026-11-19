%% =====================================================================
%% F1 Race Reasoner - Base Scenario Module
%% =====================================================================
%% This module contains the synthetic facts for a simulated F1 race.
%% =====================================================================

:- module(base_scenario, [
    team/1,
    driver/2,
    compound_pace/3,
    track_status/2,
    lap_time/3,
    stint/4,
    pit_stop/3,
    event/4
]).

%% ---------------------------------------------------------------------
%% Teams and Drivers
%% ---------------------------------------------------------------------
team(ferrari).
team(red_bull).
team(mercedes).
team(mclaren).

driver(leclerc, ferrari).
driver(sainz, ferrari).
driver(verstappen, red_bull).
driver(hamilton, mercedes).
driver(piastri, mclaren).

%% ---------------------------------------------------------------------
%% Tire Compounds and Pace
%% compound_pace(Compound, BaseTime, DegradationPerLap)
%% ---------------------------------------------------------------------
compound_pace(soft, 90.0, 0.8).
compound_pace(medium, 91.5, 0.4).
compound_pace(hard, 92.5, 0.2).

%% ---------------------------------------------------------------------
%% Track Status
%% By default, track is green. We only declare SC or VSC.
%% ---------------------------------------------------------------------
track_status(6, sc).
track_status(7, sc).
track_status(8, sc).

%% ---------------------------------------------------------------------
%% Lap Times
%% lap_time(Driver, Lap, TimeInSeconds)
%% Simulating laps for the main drivers.
%% ---------------------------------------------------------------------
% Leclerc (Ferrari)
lap_time(leclerc, 1, 90.5). lap_time(leclerc, 2, 90.8). lap_time(leclerc, 3, 91.0).
lap_time(leclerc, 4, 91.2). lap_time(leclerc, 5, 91.5). lap_time(leclerc, 6, 115.0). 
lap_time(leclerc, 7, 130.0). lap_time(leclerc, 8, 130.5). lap_time(leclerc, 9, 92.0).
lap_time(leclerc, 10, 92.2). lap_time(leclerc, 11, 92.5). lap_time(leclerc, 12, 92.8).
lap_time(leclerc, 13, 93.0). lap_time(leclerc, 14, 93.2). lap_time(leclerc, 15, 93.5).

% Verstappen (Red Bull)
lap_time(verstappen, 1, 90.2). lap_time(verstappen, 2, 90.5). lap_time(verstappen, 3, 90.8).
lap_time(verstappen, 4, 91.0). lap_time(verstappen, 5, 91.2). lap_time(verstappen, 6, 114.5).
lap_time(verstappen, 7, 129.5). lap_time(verstappen, 8, 130.0). lap_time(verstappen, 9, 91.5).
lap_time(verstappen, 10, 91.8). lap_time(verstappen, 11, 92.0). lap_time(verstappen, 12, 92.2).
lap_time(verstappen, 13, 92.5). lap_time(verstappen, 14, 92.8). lap_time(verstappen, 15, 93.0).

% Hamilton (Mercedes)
lap_time(hamilton, 1, 91.0). lap_time(hamilton, 2, 91.2). lap_time(hamilton, 3, 91.5).
lap_time(hamilton, 4, 91.8). lap_time(hamilton, 5, 92.0). lap_time(hamilton, 6, 116.0).
lap_time(hamilton, 7, 131.0). lap_time(hamilton, 8, 131.5). lap_time(hamilton, 9, 92.5).
lap_time(hamilton, 10, 92.8). lap_time(hamilton, 11, 93.0). lap_time(hamilton, 12, 93.2).
lap_time(hamilton, 13, 93.5). lap_time(hamilton, 14, 93.8). lap_time(hamilton, 15, 94.0).

% Piastri (McLaren)
lap_time(piastri, 1, 91.5). lap_time(piastri, 2, 91.8). lap_time(piastri, 3, 92.0).
lap_time(piastri, 4, 92.2). lap_time(piastri, 5, 92.5). lap_time(piastri, 6, 117.0).
lap_time(piastri, 7, 132.0). lap_time(piastri, 8, 132.5). lap_time(piastri, 9, 93.0).
lap_time(piastri, 10, 93.2). lap_time(piastri, 11, 93.5). lap_time(piastri, 12, 93.8).
lap_time(piastri, 13, 94.0). lap_time(piastri, 14, 94.2). lap_time(piastri, 15, 94.5).

%% ---------------------------------------------------------------------
%% Stints
%% stint(Driver, Compound, StartLap, EndLap)
%% ---------------------------------------------------------------------
% Leclerc starts on soft, pits on lap 5, goes to hard until the end.
stint(leclerc, soft, 1, 5).
stint(leclerc, hard, 6, 15).

% Verstappen starts on medium and does a long first stint.
stint(verstappen, medium, 1, 10).
stint(verstappen, soft, 11, 15).

% Hamilton starts on medium and doesn't pit yet.
stint(hamilton, medium, 1, 15).

%% ---------------------------------------------------------------------
%% Pit Stops
%% pit_stop(Driver, Lap, DurationSeconds)
%% ---------------------------------------------------------------------
pit_stop(leclerc, 6, 24.5). 
pit_stop(verstappen, 11, 23.8).

%% ---------------------------------------------------------------------
%% Events & Incidents
%% event(Lap, EventType, Driver, Details)
%% ---------------------------------------------------------------------
% Track limits violation
event(3, track_limits, leclerc, turn_4).

% Unsafe release from the pit lane (Sainz released into Hamilton's path)
event(6, unsafe_release, sainz, released_into(hamilton)).

% Illegal overtake under Safety Car (Hamilton overtakes Piastri on lap 7)
event(7, overtake, hamilton, overtook(piastri)).

% A normal overtake under green flag conditions (Verstappen overtakes Leclerc on lap 12)
event(12, overtake, verstappen, overtook(leclerc)).