%% =====================================================================
%% F1 Race Reasoner - Pretty Print Tests
%% =====================================================================

:- use_module('../src/explanation').
:- use_module('../src/pretty_print').

:- begin_tests(pretty_print).

test(pretty_print_fact, [nondet]) :-
    solve(driver(leclerc, ferrari), Tree),
    with_output_to(string(_), pretty_print(Tree)).

test(pretty_print_rule_negation, [nondet]) :-
    solve(is_legal_lap(leclerc, 32), Tree),
    with_output_to(string(_), pretty_print(Tree)).

test(pretty_print_conjunction, [nondet]) :-
    solve((driver(leclerc, ferrari), team(ferrari)), Tree),
    with_output_to(string(_), pretty_print(Tree)).

test(pretty_print_with_indent, [nondet]) :-
    solve(driver(leclerc, ferrari), Tree),
    with_output_to(string(_), pretty_print(Tree, 2)).

:- end_tests(pretty_print).