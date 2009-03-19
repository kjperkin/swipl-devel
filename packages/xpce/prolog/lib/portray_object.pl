/*  Part of XPCE --- The SWI-Prolog GUI toolkit

    Author:        Jan Wielemaker and Anjo Anjewierden
    E-mail:        wielemak@science.uva.nl
    WWW:           http://www.swi-prolog.org/projects/xpce/
    Copyright (C): 1985-2007, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(pce_portray_object,
	[ portray_object/1
	, portray_object/2
	]).


:- use_module(library(pce)).
:- require([ maplist/3,
	     memberchk/2
	   ]).

/** <module> Create Human readable XPCE object descriptions

Note: you may wish to  incorporate   portray_object/2  with the standard
portray mechanism of your Prolog. In that case:

==
portray(Object) :-
	object(Object), !,
	portray_object(Object).
==

Sometimes the use of  object  references  can   be  a  new  nuisance, in
particular while writing and debugging PCE   programs.  Suppose you have
done:

==
    new(@s, spatial(xref=x+w, yref=x+h/2, xref=x, yref=y+h))
==

then

==
    object(@s, S)
    S = spatial(@1234, @1235, @1236, @1237, @default, @default)
==

is not of much use.  portray_object/2 makes life easier:

==
    portray_object(@s, S)
    S = spatial(xref=x+w, yref=x+h/2, xref=x, yref=y+h)
==

More or less  expanding  the  arguments   until  they  become  readable.
portray_object/3 uses rules which  specify  how   each  object  will  be
portrayed. You can make private extensions to these rules if you like.
*/

%%	portray_class(Description, Term)
%
%	Term is a template which  may   contain  object references which
%	need to be  portrayed  recursively   (indicated  with  the  "p/"
%	prefix):
%
%	==
%	portray_class(constraint(A, B, C), _, constraint(A, B, p/C)).
%	==
%
%	Which should not touch the first two   arguments  (A and B), but
%	portrays C recursively.

vararg_class(Class) :-
	get(@pce, convert, Class, class, TheClass),
	get(TheClass, term_names, @nil).

portray_class(+(A, B), +(p/A, p/B)).
portray_class(-(A, B), -(p/A, p/B)).
portray_class(*(A, B), *(p/A, p/B)).
portray_class(/(A, B), /(p/A, p/B)).
portray_class(=(A, B), =(p/A, p/B)).
portray_class(==(A, B), ==(p/A, p/B)).
portray_class(\==(A, B), \==(p/A, p/B)).
portray_class(if(A,B,C), if(p/A, p/B, p/C)).
portray_class(while(A,B), while(p/A, p/B)).
portray_class(when(A,B,C), when(p/A, p/B, p/C)).
portray_class(attribute(A, B), attribute(A, p/B)).
portray_class(constraint(A, B, C), constraint(A, B, p/C)).
portray_class(handler(A, B, C), handler(A, p/B, p/C)).
portray_class(identity(A, A), identity(A)).
portray_class(identity(A, B), identity(A, B)).
portray_class(line(A, B, C, D), line(A, B, C, D)).
portray_class(link(A, A, _), link(A)).
portray_class(link(A, B, C), link(A, B, p/C)).
portray_class(number(A), A).
portray_class(node(A), node(p/A)).
portray_class(text(A,B,C), text(p/A, B, C)).
portray_class(button(A,B), button(A, p/B)).
portray_class(real(A), A).
portray_class(type(Name, _, _, _), Name).
portray_class(spatial(A, B, C, D, @default, @default), spatial(p/A, p/B, p/C, p/D)).
portray_class(spatial(A, B, C, D, @nil, @nil), spatial(p/A, p/B, p/C, p/D)).
portray_class(spatial(A, B, C, D, E, F), spatial(p/A, p/B, p/C, p/D, p/E, p/F)).
portray_class(string(A), A).
portray_class(click_gesture(A, B, C, D, E, F),
	      click_gesture(A, p/B, C, p/D, p/E, p/F)).
portray_class(handle(A,B,C,D), handle(p/A, p/B, C, D)).
portray_class(quote_function(X), quote_function(p/X)).
portray_class(Term, NewTerm) :-
	functor(Term, Functor, _),
	vararg_class(Functor), !,
	Term =.. [Functor|Arguments],
	maplist(tag_p, Arguments, NewArguments),
	NewTerm =.. [Functor|NewArguments].
portray_class(A, A).

tag_p(X, p/X).

%%	global_object(+Ref)
%
%	Declare commonly known objects

global_object(@nil).
global_object(@default).
global_object(@arg1).
global_object(@arg2).
global_object(@arg3).
global_object(@arg4).
global_object(@arg5).
global_object(@arg6).
global_object(@arg7).
global_object(@arg8).
global_object(@arg9).
global_object(@arg10).
global_object(@receiver).
global_object(@event).
global_object(@pce).
global_object(@prolog).
global_object(@display).
global_object(@classes).
global_object(@cursor_names).
global_object(@event_tree).
global_object(@white_image).
global_object(@grey12_image).
global_object(@grey25_image).
global_object(@grey50_image).
global_object(@grey75_image).
global_object(@black_image).
global_object(@on).
global_object(@off).

%%	portray_object(@Object)
%
%	Prints the result of portray_object/2 on the display.

portray_object(Object) :-
	portray_object(Object, Term),
	print(Term), nl, !.


%%	portray_object(@Object, -Term)
%
%	Expands the object description of  Object   in  a human readable
%	form and returs this in Term.   portray_object/2  uses the rules
%	found under portray_class/2.

portray_object(Obj, Term) :-
	portray_object(Obj, Term, []).

portray_object(@Object, @Object, _) :-
	global_object(@Object), !.
portray_object(Obj, '<recursive>'(Obj), Done) :-
	memberchk(Obj, Done), !.
portray_object(@Object, Term, Done) :-
	object(@Object, Description),
	portray_class(Description, Result),
	portray_description(Result, Term, [@Object|Done]), !.
portray_object(Term, Term, _).

portray_description(Result, Term, Done) :-
	Result =.. Arguments,
	maplist(portray_argument(Done), Arguments, List), !,
	Term =.. List.
portray_description(Term, Term, _).

portray_argument(Done, p/Object, Term) :- !,
	portray_object(Object, Term, Done).
portray_argument(_, Term, Term).
