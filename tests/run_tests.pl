%% =====================================================================
%% F1 Race Reasoner - Test Suite Entry Point
%% =====================================================================
%% This file consults every tests/*_tests.pl file, then leaves
%% execution to `run_tests/0` (invoked via swipl -g run_tests).
%%
%% Usage (from the repository root):
%%   swipl -g run_tests -t halt tests/run_tests.pl
%% =====================================================================

:- consult('tests/base_scenario_tests.pl').
:- consult('tests/facts_tests.pl').
:- consult('tests/rules_legality_tests.pl').
:- consult('tests/rules_penalties_tests.pl').
:- consult('tests/strategy_tests.pl').
:- consult('tests/explanation_tests.pl').
:- consult('tests/pretty_print_tests.pl').
:- consult('tests/metainterpreter_robustness_tests.pl').