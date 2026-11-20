%% =====================================================================
%% F1 Race Reasoner - Meta-Interpreter Tests
%% =====================================================================

:- use_module('../src/explanation').

:- begin_tests(metainterpreter_robustness).

% R1: solve/2 returns a compound term, never a raw atom.
test(solve_returns_compound, [nondet]) :-
    solve(driver(leclerc, ferrari), Tree),
    compound(Tree),
    Tree = proof(_, _).

% R2: solve/2 on a conjunction returns conj/2 inside proof/2.
test(solve_returns_conj_term) :-
    solve((driver(leclerc, ferrari), team(ferrari)), Tree),
    Tree = proof(_, conj(_, _)).

% R3: solve/3 with depth 0 fails cleanly (no crash, no exception).
test(solve_depth_zero_fails_cleanly) :-
    \+ solve(driver(leclerc, ferrari), _, 0).

% R4: solve/2 handles a built-in predicate without throwing.
test(solve_builtin_goal, [nondet]) :-
    solve(atom(leclerc), Tree),
    Tree = proof(atom(leclerc), builtin).

% R5: explain/2 on a complex nested rule (penalty → illegal_overtake
%     → event + lap_status) produces a rule tree without crashing.
test(explain_complex_nested_rule, [nondet]) :-
    with_output_to(string(_),
                   explain(penalty(hamilton, 7, drive_through), E)),
    E = proof(_, rule(_)).

% R6: explain/2 on a conjunction returns a conj tree.
test(explain_conjunction, [nondet]) :-
    with_output_to(string(_),
                   explain((driver(leclerc, ferrari), team(ferrari)), E)),
    E = proof(_, conj(_, _)).

% R7: explain/2 on a rule whose body contains NAF in the chain
%     (fully_legal_lap → \+ illegal_action).
test(explain_rule_with_naf, [nondet]) :-
    with_output_to(string(_),
                   explain(fully_legal_lap(verstappen, 1), E)),
    E = proof(_, rule(_)).

% R8: explain/2 on a well-defined but failing goal returns no_proof/1
%     and does not crash.
test(explain_no_proof_well_defined) :-
    once(( with_output_to(string(Out),
                          explain(exceeded_track_limits(leclerc, 32), E)),
           E = no_proof(_),
           sub_string(Out, _, _, _, "No proof found")
         )).

:- end_tests(metainterpreter_robustness).