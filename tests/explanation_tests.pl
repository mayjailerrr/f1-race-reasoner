%% =====================================================================
%% F1 Race Reasoner - Explanation Tests
%% =====================================================================

:- use_module('../data/base_scenario').
:- use_module('../src/explanation').

:- begin_tests(explanation).

% Test 48: solve/2 produces a fact proof.
test(solve_fact, [nondet]) :-
    solve(driver(leclerc, ferrari),
          proof(driver(leclerc, ferrari), fact)).

% Test 49: solve/2 produces a rule proof with a nested body.
test(solve_rule) :-
    solve(exceeded_track_limits(leclerc, 3),
          proof(exceeded_track_limits(leclerc, 3), rule(_))).

% Test 50: solve/2 handles negation as failure.
test(solve_negation) :-
    solve(is_legal_lap(leclerc, 32),
          proof(is_legal_lap(leclerc, 32),
                rule(proof(\+ exceeded_track_limits(leclerc, 32),
                            not_provable(exceeded_track_limits(leclerc, 32)))))).

% Test 51: solve/2 fails for an unprovable goal.
test(solve_unprovable) :-
    \+ solve(exceeded_track_limits(leclerc, 32), _).

% Test 52: solve/3 respects the depth budget.
test(solve_depth_exhausted) :-
    \+ solve(is_legal_lap(leclerc, 32), _, 1).

:- end_tests(explanation).

:- begin_tests(explain).

% Test 53: explain/2 succeeds on a penalty rule and returns a tree.
test(explain_penalty_success, [nondet]) :-
    with_output_to(string(_), explain(penalty(leclerc, 3, P), E)),
    P == five_second_penalty,
    E = proof(_, _).

% Test 54: explain/2 on an unprovable goal returns no_proof/1.
test(explain_no_proof, [nondet]) :-
    with_output_to(string(Out), explain(penalty(leclerc, 32, _), E)),
    E = no_proof(_),
    sub_string(Out, _, _, _, "No proof found").

% Test 55: explain/2 works for legality rules.
test(explain_illegal_overtake, [nondet]) :-
    with_output_to(string(_),
                   explain(illegal_overtake(hamilton, piastri, 7), E)),
    E = proof(_, _).

% Test 56: explain/2 works for strategy rules.
test(explain_legal_strategy, [nondet]) :-
    with_output_to(string(_),
                   explain(legal_strategy(leclerc, [soft, hard]), E)),
    E = proof(_, _).

:- end_tests(explain).