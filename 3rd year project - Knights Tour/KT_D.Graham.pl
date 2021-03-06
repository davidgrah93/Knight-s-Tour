%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: David Graham
% Date: 13/04/2016
% File:
% Comment:
%
% Display Lists in FULL
:- set_prolog_flag(toplevel_print_options,[quoted(true), portray(true)]).

% Use PCE EMACS as editor
:- set_prolog_flag(editor, pce_emacs).

%  Allow predicates to be spaced without Warnings
:- style_check(-discontiguous).


% Dynamic predicates
:- dynamic(display/3).
:- dynamic(browser/1).

:- dynamic(squares/1).
:- dynamic(knight/2).
:- dynamic(square/4).

:- dynamic(open/1).
:- dynamic(closed/1).
:- dynamic(children/1).
:- dynamic(initial/1).
:- dynamic(current/1).
:- dynamic(search_mode/1).
:- dynamic(drawn_knight/1).

:- dynamic(arc/2).

:- dynamic( gamesize/2 ).
%boardsize
gamesize(5,5).
% gamesize(8, 8).

%space size
squaresize(40).
kt_start_colour(yellow).

%% Search predicates
visited( [ ] ).
unvisited( [ ] ).

open( [ ] ).
closed( [ ] ).

children( [ ] ).


:- nl, nl,
	write('***********************************************'), nl,
	write('Type start to run Knight''s Tour'), nl,
	write('***********************************************'), nl,
	nl, nl.

/********************************************/
/*Clean the display and all assertions made*/

cleanup:-
	clean_graphics,
	clean_knight,
	!.

clean_graphics:-
	retract(display(_,_,_)), !,
	clean_graphics.
clean_graphics:-
	retract(browser(_)), !,
	clean_graphics.
clean_graphics:-
	retract(square(_,_,_,_)), !,
	clean_graphics.
clean_graphics:-
	!.

clean_knight:-
	retract(knight(_,_)), !,
	clean_knight.
clean_knight:-
	retract(current(_)), !,
	clean_knight.
clean_knight:-
	retract(initial(_)), !,
	clean_knight.
clean_knight:-
	retract(squares(_)), !,
	clean_knight.
clean_knight:-
	retract(open(_)), !,
	clean_knight.
clean_knight:-
	retract(closed(_)), !,
	clean_knight.
clean_knight:-
	retract(children(_)), !,
	clean_knight.
clean_knight:-
	retract(arc(_,_)), !,
	clean_knight.

clean_knight:-
	!.

initialise:-
	assert(squares([])),
	assert(drawn_knight(no)), !.

start:-
	cleanup,
	initialise,
	draw_graphics,
	player.

reset:-
	browser(Browser),
	send(Browser, destroy),
	retract(drawn_knight(_)),
	start.

close:-
	browser(Browser),
	send(Browser, destroy),
	retract(drawn_knight(_)).


/**************************************/
/*Draw display graphics		      */

draw_graphics:-
	%size and name of the frame
	gamesize(GWidth, GHeight),
	squaresize(SqSize),
	XWidth is GWidth*SqSize,
	YHeight is GHeight*SqSize,
	Offset is round(SqSize/3),
	PictureH is YHeight+round(1.2*Offset),
	PictureW is XWidth+round(1.2*Offset),
	new(Picture, picture('KNIGHT''S TOUR', size(PictureW, PictureH)) ),
	assert(display(Picture, XWidth, YHeight)), !,

	%creates a frame for text to be displayed
	send( new(Browser, browser), right, Picture),
	assert(browser(Browser)), !,

	send(Picture, display, new(Background, box(XWidth, YHeight))),
	send(Picture, display(Background, point(0, 0))),
	send(Background, fill_pattern, colour(green)),

	drawGridSquares,

	%create space in the environment for buttons
	send(new(Dialog, dialog), below, Browser),
	%add following buttons to the frame
	send(Dialog, append,
	     button('Board Size', message(@prolog, change_board_size))),
	send(Dialog, append,
	     button('Reset', message(@prolog, reset))),
	send(Dialog, append,
	     button('Close', message(@prolog, close))),
	send(Dialog, append,
	     button('Exit', message(@prolog, halt))),

	send(new(Dialog1, dialog), above, Browser),
	send(Dialog1, append,
	     button('BreadthF Search', message(@prolog, bf_search))),
	send(Dialog1, append,
	     button('DepthF Search', message(@prolog, df_search))),
	send(new(Dialog2, dialog), above, Browser),
	send(Dialog2, append,
	     button('DepthF Path', message(@prolog, depth_first_path))),
	send(Dialog2, append,
	     button('DepthF ClosedPath', message(@prolog, depth_first_closedpath))),
	send(Dialog2, append,
	     button('BestF Path', message(@prolog, bestf_search))),

	send(Picture, open).

drawGridSquares:-
	drawColumns(0).
drawColumns(Column):-
	gamesize(_W, Column), !.
drawColumns(Column):-
	Next is Column+1,
	drawRows(0, Next),
	drawColumns(Next).
drawRows(XWidth, _Column):-
	gamesize(XWidth, _YHeight), !.
drawRows(Xin, Column):-
	X is Xin+1,
	squaresize(SqSize),
	Xval is X*SqSize,
	Yval is Column*SqSize,
	make_box(Xval, Yval, green, _GID),
	retract( squares( List )),
	assert( squares( [[Xval, Yval]|List] )),
	drawRows(X, Column).

make_box(X, Y, Colour, GID):-
	squaresize(SqSize),
	display(P, _Length, _Width),
	send(P, display, new(GID, box(SqSize, SqSize))),
	X1 is X - SqSize,
	Y1 is Y - SqSize,
	send(P, display(GID, point(X1,Y1))),
	send(GID, fill_pattern, colour(Colour)),
	assert( square([X, Y], SqSize, GID, Colour) ), !.

/*Draw message on browser*/
display_message(Message):-
	browser(Browser),
	send(Browser, append, Message), !.

/***************************************************************/
%% User Interaction Predicates

% reads in user input for new board size and recreated board
change_board_size:-
	write('Give New Width:'), read( Width ),
	write('Give New Height:'), read( Height ),
	display(Picture, _XWidth, _YHeight),
	send(Picture, destroy),
	retract( gamesize( _A, _B) ),
	assert( gamesize(Width, Height) ),
	start,
	!.

%Text Display
send_graphics_text(X, Y, Text, Color):-
	display(Picture, _Length, _Width),
	squaresize(SqSize),
	Offset is 2*SqSize//3,
	GX is X - Offset,
	GY is Y - Offset,
	send(Picture, display, new(GID, text(Text, left, bold))),
	send(Picture, display(GID, point(GX, GY))),
	send(GID, colour(Color)),
	!.

/***************************************************************/
/***************************************************************/
/***************************************************************/
/*                                                             */
/*                    Main Program Body	                       */
/*                                                             */
/***************************************************************/
/***************************************************************/

/*Detect location of mouse at click and draw knight at that position*/

:- pce_global(@icon_recogniser, make_icon_recogniser).

make_icon_recogniser(G) :-
	new(M, move_gesture),
	new(G, handler_group(M)).

player:-
	gamesize(H, W),
	squaresize(SqSize),
	H2 is H * SqSize,
	W2 is W * SqSize,
	display(P, H2, W2),
	send(P, recogniser,
		click_gesture(left, '', single,
		message(@prolog, create_knight, @event?position))),
	!.

create_knight(Position):-
	drawn_knight(no),
	display(P, _Ax, _Ay),
	squaresize(SqSize),
	new(Box, box(SqSize, SqSize)),
	send(Box, recogniser, @icon_recogniser),
	send(P, display, Box, Position),
	get(Box, position, point(X,Y)),
	write('Click at '), write(X), write(' '), write(Y), nl,
	send(Box, destroy),
	create_knight(X,Y).

create_knight(_):-
	display_message('Knight already placed'), !.

create_knight(X,Y):-
	squaresize(SqSize),
	get_box_coord(X, SqSize, X1),
	get_box_coord(Y, SqSize, Y1),

	write('Knight Start Position: '),
	write(X1), write(' '), write(Y1), nl,
	kt_start_colour(KTColor),
	square([X1, Y1], SqSize, GID, Colour),
	send(GID, fill_pattern, colour(KTColor)), !,
	% knight start position represented with 'K0'
	send_graphics_text(X1, Y1, 'K0', blue),

	retract( square([X1, Y1], SqSize, GID, Colour) ),!,
	assert(	square([X1, Y1], SqSize, GID, KTColor) ),!,
	assert(knight([X1, Y1], GID)),!,

	retract(drawn_knight(_)),
	assert(drawn_knight(yes)), !,
	write('Knight Placed'), nl.

get_box_coord(Coord, SqSize, SqSize):-
	Coord < SqSize,
	!.
% Detect click location
get_box_coord(Coord, SqSize, GridCoord):-
	N is (Coord//SqSize),
	GridCoord is (N+1)*SqSize,
	!.

/************************************************/
% node( Id, GridX, GridY) eg for 8*8 GridX|GridY mem [1,8]
:-dynamic( node/3 ).
% node_children( Id, ListOfChildren ).
:-dynamic( node_children/2 ).
:-dynamic( open_closed/2 ).

bf_search:-
	knight([GX, GY], _GID),
	!,
	breadth_first(GX, GY)
	.
bf_search:-
	writeln('Please select knight start position'),
	!.

breadth_first(StartX, StartY):-
	gensym(node, NodeId),
	assert( node( NodeId, StartX, StartY ) ),
	assert( open_closed( [StartX-StartY], [] ) ),
	assert( search_mode( breadth_first ) ),
	find_path( Path ),
	display_path( 0, Path ),
	!.

df_search:-
	knight([GX, GY], _GID),
	!,
	depth_first(GX, GY)
	.
df_search:-
	writeln('Please select knight start position'),
	!.

depth_first(StartX, StartY):-
	gensym(node, NodeId),
	assert( node( NodeId, StartX, StartY ) ),
	assert( open_closed( [StartX-StartY], [] ) ),
	assert( search_mode( depth_first ) ),
	find_path( Path ),
	display_path( 0, Path ),
	!.

depth_first_path:-
	knight([GX, GY], _GID),
	!,
	depth_first_path(GX, GY)
	.

depth_first_path:-
	writeln('Please select knight start position'),
	!.

depth_first_path(StartX, StartY):-
	gensym(node, NodeId),
	assert( node( NodeId, StartX, StartY ) ),
	assert( search_mode( depth_first ) ),
	df_path( [StartX-StartY], [], Path ),
	display_path( 0, Path ),
	!.

depth_first_closedpath:-
	knight([GX, GY], _GID),
	!,
	depth_first_closedpath(GX, GY)
	.

depth_first_closedpath:-
	writeln('Please select knight start position'),
	!.


depth_first_closedpath(StartX, StartY):-
	gensym(node, NodeId),
	assert( node( NodeId, StartX, StartY ) ),
	assert( search_mode( depth_first ) ),
	df_path_closed( [StartX-StartY], [], Path ),
	display_path( 0, Path ),
	!.

bestf_search:-
	knight([GX, GY], _GID),
	!,
	best_first(GX, GY)
	.
bestf_search:-
	writeln('Please select knight start position'),
	!.

best_first(StartX, StartY):-
	gensym(node, NodeId),
	assert( node( NodeId, StartX, StartY ) ),
	assert( search_mode( best_first ) ),
	find_best_first_path( [StartX-StartY], [], Path ),
	display_path( 0, Path ),
	!.

display_path( _N, [] ):-
	writeln(' Finished'), !.
display_path( N, [NodeX-NodeY | Rest] ):-
	writeln('\tNode':N-NodeX-NodeY ),
	atom_concat('K', N, String),
	send_graphics_text(NodeX, NodeY, String, blue),
	M is N + 1,
	display_path( M, Rest ),
	!.

/*
breadth_first
Start search from root (initial state)
Search all nodes at current depth, then expand
Memory requirements exponential with depth
Algoithm:
	Initialise Open = [Root], Closed = [empty]
	while Open not empty
	N= first node from Open
	if N is a goal state return SUCCESS and PATH
		otherwise Place N on Closed
			generate C set of children of N (if it has any)
			add C to TAIL of Open
	return FAILURE
*/

% goal state is when Open is empty -> all spaces visited => return PATH
find_path( [ ] ):-
	open_closed([], _Closed),
	!.

find_path([NodeX-NodeY | Path]):-
	search_mode( breadth_first ), !,
	open_closed([NodeX-NodeY |Open], Closed),
	retract( open_closed([NodeX-NodeY |Open], Closed) ),
	% Find avaliable spaces
	generate_children( NodeX-NodeY, Children),
	% now delete invalid children - outside of board
	delete_invalid_children(Children, ValidChildren),
	% now delete children already visited
	delete_closed_children(ValidChildren, Closed, OpenChildren),
	delete_closed_children(Open, OpenChildren, TempOpen),
	append(TempOpen, OpenChildren, NewOpen),
	assert( open_closed(NewOpen, [NodeX-NodeY | Closed]) ),
	find_path( Path ),
	!.

find_path([NodeX-NodeY | Path]):-
	search_mode( depth_first ), !,
	open_closed([NodeX-NodeY |Open], Closed),
	retract( open_closed([NodeX-NodeY |Open], Closed) ),
	generate_children( NodeX-NodeY, Children),
	% now delete invalid children - outside of board
	delete_invalid_children(Children, ValidChildren),
	% now delete children already visited
	delete_closed_children(ValidChildren, Closed, OpenChildren),
	delete_closed_children(OpenChildren, Open, OpenChildren2),
	append(OpenChildren2, Open, NewOpen),
	length( NewOpen, LN1),
	sort( NewOpen, Test),
	length( Test, LN2),
	writeln('List lengths ':LN1-LN2),
	assert( open_closed(NewOpen, [NodeX-NodeY | Closed]) ),
	find_path( Path ),
	!.

%is this being used????
find_path([NodeX-NodeY | Path]):-
	search_mode( best_first ), !,
	open_closed([NodeX-NodeY |Open], Closed),
	retract( open_closed([NodeX-NodeY |Open], Closed) ),
	generate_children( NodeX-NodeY, Children),
	% now delete invalid children - outside of board
	delete_invalid_children(Children, ValidChildren),
	% now delete children already visited
	delete_closed_children(ValidChildren, Closed, []),
	% pick_best_child(OpenChildren, BestChild),
	assert( open_closed([], [NodeX-NodeY | Closed]) ),
	find_path( Path ),
	!.

% This provides a path
df_path(Open, Closed, Path):-
	% First condition no nodes left to visit
	Open == [],
	% Second Condition is All Nodes visited
	% Closed of correct length
	gamesize(W,H),
	Size is W*H,
	length(Closed, Size), !,
	reverse(Closed, Path).
df_path(Open, Closed, Path):-
	search_mode( depth_first ), !,
	member( NodeX-NodeY, Open),
	generate_children( NodeX-NodeY, Children),
	% now delete invalid children - outside of board
	delete_invalid_children(Children, ValidChildren),
	% now delete children already visited
	delete_closed_children(ValidChildren, Closed, OpenChildren),
	df_path(OpenChildren, [NodeX-NodeY |Closed], Path).

% Unkown if this provides a closed path, takes a great amount of time
df_path_closed(Open, Closed, Path):-
	% First condition no nodes left to visit
	Open == [],
	% Second Condition is All Nodes visited
	% Closed of correct length
	gamesize(W,H),
	Size is W*H,
	length(Closed, Size),
	Closed = [LastX-LastY | _More],
	generate_children( LastX-LastY, Children),
	node( _NodeId, StartX, StartY ),
	member( StartX-StartY, Children),
	reverse(Closed, Path).
df_path_closed(Open, Closed, Path):-
	search_mode( depth_first ),
	member( NodeX-NodeY, Open),
	generate_children( NodeX-NodeY, Children),
	% now delete invalid children - outside of board
	delete_invalid_children(Children, ValidChildren),
	% now delete children already visited
	delete_closed_children(ValidChildren, Closed, OpenChildren),
	df_path_closed(OpenChildren, [NodeX-NodeY |Closed], Path).

%Provides successful path
find_best_first_path( Open, Closed, Path ):-
	% First condition no nodes left to visit
	Open == [],
	% Second Condition is All Nodes visited
	% Closed of correct length
	gamesize(W,H),
	Size is W*H,
	length(Closed, Size),
	reverse(Closed, Path).
find_best_first_path( Open, Closed, Path ):-
	search_mode( best_first ),
	most_constrained_member( NodeX-NodeY, Open, Closed),
	generate_children( NodeX-NodeY, Children),
	% now delete invalid children - outside of board
	delete_invalid_children(Children, ValidChildren),
	% now delete children already visited
	delete_closed_children(ValidChildren, Closed, OpenChildren),
	find_best_first_path(OpenChildren, [NodeX-NodeY |Closed], Path).

%looks for avaliabled space that would have the fewest children
most_constrained_member( NodeX-NodeY, Open, Closed):-
	most_constrained_member(NodeX-NodeY, Open, Closed, Count),
	Count > 0,
	Closed = [TopClosedNodeX-TopClosedNodeY | _More],
	assert(tried_node(TopClosedNodeX-TopClosedNodeY, NodeX-NodeY) ).
most_constrained_member( NodeX-NodeY, Open, _Closed):-
	member(NodeX-NodeY, Open).

% As stands only produces ONE answer
most_constrained_member(NodeX-NodeY, [NodeX-NodeY], Closed, Count):-
	generate_children( NodeX-NodeY, Children),
	% now delete invalid children - outside of board
	delete_invalid_children(Children, ValidChildren),
	% now delete children already visited
	delete_closed_children(ValidChildren, Closed, OpenChildren),
	length(OpenChildren, Count).
most_constrained_member(NodeX-NodeY, [NodeX-NodeY|More], Closed, Count):-
	most_constrained_member([], More, Closed, Count1),
	generate_children( NodeX-NodeY, Children),
	% now delete invalid children - outside of board
	delete_invalid_children(Children, ValidChildren),
	% now delete children already visited
	delete_closed_children(ValidChildren, Closed, OpenChildren),
	length(OpenChildren, Count),
	Count =< Count1.
most_constrained_member(NodeX-NodeY, [[]|More], Closed, Count):-
	most_constrained_member(NodeX-NodeY, More, Closed, Count).


%ref - http://stackoverflow.com/questions/2849045/if-in-prolog
delete_invalid_children([], []):- !.
% if valid
delete_invalid_children([CX-CY|Children], [CX-CY|OpenChildren]):-
	gamesize(Width, Height),
	squaresize(Size),
	CX >  0,
	XWidth is (Size*Width)+1,
	CX <  XWidth,
	YHeight is (Size*Height)+1,
	CY >  0,
	CY <  YHeight, !,
	% Check Head of List
	% Check rest of List
	delete_invalid_children(Children, OpenChildren),
	!.
% if invalid
delete_invalid_children([_CX-_CY|Children], OpenChildren):-
	% Check rest of List
	delete_invalid_children(Children, OpenChildren),
	!.

delete_closed_children([], _Closed, []):- !.
delete_closed_children([CX-CY|Children], Closed, OpenChildren):-
	member(CX-CY, Closed),%closes the child
	delete_closed_children(Children, Closed, OpenChildren),
	!.
delete_closed_children([CX-CY|Children], Closed, [CX-CY|OpenChildren]):-
	delete_closed_children(Children, Closed, OpenChildren),
	!.

/************************************************/
% origin is Top Left, Increment is 40
% Node-80-80
generate_children( NodeX-NodeY, Children):-
	gen_children1( NodeX-NodeY, Child1X-Child1Y),
	gen_children2( NodeX-NodeY, Child2X-Child2Y),
	gen_children3( NodeX-NodeY, Child3X-Child3Y),
	gen_children4( NodeX-NodeY, Child4X-Child4Y),
	gen_children5( NodeX-NodeY, Child5X-Child5Y),
	gen_children6( NodeX-NodeY, Child6X-Child6Y),
	gen_children7( NodeX-NodeY, Child7X-Child7Y),
	gen_children8( NodeX-NodeY, Child8X-Child8Y),
	Children = [Child1X-Child1Y, Child2X-Child2Y, Child3X-Child3Y,
		    Child4X-Child4Y, Child5X-Child5Y, Child6X-Child6Y,
		    Child7X-Child7Y, Child8X-Child8Y],
	!.

% Knight movements:
% Two Up One-Right
gen_children1( NodeX-NodeY, Child1X-Child1Y):-
	Child1X is NodeX+40,
	Child1Y is NodeY-80,
	!.
% Two-Right One-Up
gen_children2( NodeX-NodeY, Child2X-Child2Y):-
	Child2X is NodeX+80,
	Child2Y is NodeY-40,
	!.
% Two-Right One-Down
gen_children3( NodeX-NodeY, Child3X-Child3Y):-
	Child3X is NodeX+80,
	Child3Y is NodeY+40,
	!.
% Two-Down One-Right
gen_children4( NodeX-NodeY, Child4X-Child4Y):-
	Child4X is NodeX+40,
	Child4Y is NodeY+80,
	!.
% Two-Down One-Left
gen_children5( NodeX-NodeY, Child5X-Child5Y):-
	Child5X is NodeX-40,
	Child5Y is NodeY+80,
	!.
% Two-Left One-Down
gen_children6( NodeX-NodeY, Child6X-Child6Y):-
	Child6X is NodeX-80,
	Child6Y is NodeY+40,
	!.
% Two-Left One-Up
gen_children7( NodeX-NodeY, Child7X-Child7Y):-
	Child7X is NodeX-80,
	Child7Y is NodeY-40,
	!.
% Two-Up One-Left
gen_children8( NodeX-NodeY, Child8X-Child8Y):-
	Child8X is NodeX-40,
	Child8Y is NodeY-80,
	!.

/************************************************/
% start program on loading
:- start.


