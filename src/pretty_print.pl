%% =====================================================================
%% F1 Race Reasoner - Pretty Printer for Proof Trees
%% =====================================================================
%% Formats the structured proof trees produced by src/explanation.pl
%% into a readable, indented textual representation.
%%
%% Output format:
%%   Each node starts with "+--" and is indented three spaces per level.
%%   Leaves (facts, built-ins, not-provable goals) carry a tag in
%%   parentheses to make their nature explicit.
%%
%% Example:
%%   +-- is_legal_lap(leclerc, 32)
%%       +-- \+ exceeded_track_limits(leclerc, 32)  [not provable]
%% =====================================================================

:- module(pretty_print, [
    pretty_print/1,
    pretty_print/2
]).

%% pretty_print(+Tree) is det.
%
%  Prints a readable, indented representation of Tree to standard output.
%
pretty_print(Tree) :-
    pretty_print(Tree, 0).

%% pretty_print(+Tree, +Indent) is det.
%
%  Same as pretty_print/1 but starting at the given indent level.
%  Indent is the number of three-space blocks to prefix the output.
%
pretty_print(proof(Goal, fact), Indent) :- !,
    indent(Indent),
    format("+-- ~w  [fact]~n", [Goal]).
pretty_print(proof(Goal, builtin), Indent) :- !,
    indent(Indent),
    format("+-- ~w  [builtin]~n", [Goal]).
pretty_print(proof(Goal, rule(Body)), Indent) :- !,
    indent(Indent),
    format("+-- ~w~n", [Goal]),
    Indent1 is Indent + 1,
    pretty_print(Body, Indent1).
pretty_print(proof((A, B), conj(PA, PB)), Indent) :- !,
    indent(Indent),
    format("+-- conjunction~n"),
    Indent1 is Indent + 1,
    indent(Indent1), format("~w~n", [A]),
    pretty_print(PA, Indent1),
    indent(Indent1), format("~w~n", [B]),
    pretty_print(PB, Indent1).
pretty_print(proof(\+ G, not_provable(G)), Indent) :- !,
    indent(Indent),
    format("+-- \\+ ~w  [not provable]~n", [G]).

%% indent(+N) is det.
%
%  Prints N blocks of three spaces.
%
indent(0) :- !.
indent(N) :-
    N > 0,
    format("   "),
    N1 is N - 1,
    indent(N1).