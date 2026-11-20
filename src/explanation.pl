%% =====================================================================
%% F1 Race Reasoner - Explanation Module (Meta-Interpreter)
%% =====================================================================
%% A meta-interpreter that treats clauses as data and produces a
%% structured SLD proof tree for a goal.
%%
%% Proof tree grammar:
%%
%%   Tree ::= true                         % goal trivially true
%%          | fact                         % user-defined fact
%%          | builtin                      % built-in predicate
%%          | rule(Tree)                   % user rule body
%%          | conj(Tree, Tree)             % conjunction (A, B)
%%          | not_provable(Goal)           % negation as failure
%%
%%   proof(Goal, Tree) pairs Goal with the tree that proves it.
%% =====================================================================

:- module(explanation, [
    solve/2,
    solve/3,
    explain/2
    
]).

:- use_module('../data/base_scenario').
:- use_module('../src/facts').
:- use_module('../src/rules_legality').
:- use_module('../src/rules_penalties').
:- use_module('../src/strategy').
:- use_module('../src/pretty_print').

%% solve(+Goal, -Tree) is nondet.
%
%  Tree is a structured proof of Goal obtained by SLD resolution.
%  Uses the default depth budget of 100.
%
solve(Goal, Tree) :-
    solve(Goal, Tree, 100).

%% solve(+Goal, -Tree, +MaxDepth) is nondet.
%
%  Same as solve/2, bounded by MaxDepth recursive steps. Each case
%  ends with a cut or falls through to a single fallback clause so
%  solve/3 commits to the first proof found: the module explains one
%  derivation, it does not enumerate all possible proofs.
%
solve(_, _, 0) :- !, fail.
solve(true, true, _) :- !.
solve((A, B), proof((A, B), conj(PA, PB)), D) :-
    !,
    D1 is D - 1,
    solve(A, PA, D1),
    solve(B, PB, D1).
solve(\+ G, proof(\+ G, not_provable(G)), D) :-
    !,
    \+ solve(G, _, D).
solve(Goal, proof(Goal, builtin), _) :-
    \+ has_clause(Goal),
    call(Goal).
solve(Goal, proof(Goal, fact), _) :-
    has_clause(Goal),
    clause(Goal, true),
    !.
solve(Goal, proof(Goal, rule(BodyProof)), D) :-
    has_clause(Goal),
    clause(Goal, Body),
    Body \== true,
    D1 is D - 1,
    solve(Body, BodyProof, D1),
    !.
solve(Goal, proof(Goal, builtin), _) :-
    \+ has_clause(Goal),
    call(Goal).

%% is_builtin(+Goal) is semidet.
%
%  True if Goal refers to a built-in or system-imported predicate.
%  Control constructs (`,`, `;`, `->`, `\+`, `!`) have no predicate
%  properties and are handled by the fallback clause of solve/3.
%
is_builtin(Goal) :-
    catch(predicate_property(Goal, P), _, fail),
    (   P == built_in
    ;   P = imported_from(system)
    ).

%% has_clause(+Goal) is semidet.
%
%  True if Goal has at least one user-defined clause. Fails for
%  built-in predicates and for undefined predicates.
%
has_clause(Goal) :-
    catch(clause(Goal, _), _, fail).

%% print_tree(+Tree) is det.
%
%  Minimal tree printer for debugging.
%
print_tree(proof(Goal, fact)) :-
    format("~w [fact]~n", [Goal]).
print_tree(proof(Goal, builtin)) :-
    format("~w [builtin]~n", [Goal]).
print_tree(proof(Goal, rule(Body))) :-
    format("~w~n", [Goal]),
    print_tree(Body).
print_tree(proof((A, B), conj(PA, PB))) :-
    format("(~w, ~w)~n", [A, B]),
    print_tree(PA),
    print_tree(PB).
print_tree(proof(\+ G, not_provable(G))) :-
    format("not provable: ~w~n", [G]).

%% explain(+Goal, -Explanation) is det.
%
%  Solves Goal with once(solve/2) and prints a readable proof tree to
%  standard output. Explanation unifies with the proof tree on success
%  and with no_proof(Goal) when the goal is not provable. The once/1
%  keeps explain/2 deterministic: the caller gets exactly one outcome.
%
explain(Goal, Explanation) :-
    (   once(solve(Goal, Tree))
    ->  Explanation = Tree,
        format("~n=== Explanation for: ~w ===~n", [Goal]),
        pretty_print(Tree),
        format("=== End of explanation ===~n", [])
    ;   Explanation = no_proof(Goal),
        format("~n=== Explanation for: ~w ===~n", [Goal]),
        format("No proof found: the goal is not provable.~n", []),
        format("=== End of explanation ===~n", [])
    ).