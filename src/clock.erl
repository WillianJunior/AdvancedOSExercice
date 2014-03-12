-module(clock).
-export([start/0, restarter/0, loop/1, add_new_sensor/1]).
-define (CLOCK_PERIOD_MS, 1000).

% clock spawner
start() ->
	spawn(?MODULE, restarter, []).

% the restarter makes sure that except when we explicitly
% killed the process, it will restart itself
restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, [[]]),
	register(clock, Pid),
	receive
		{'EXIT', _Pid, normal} ->
			io:format("[clock] terminated normally~n");
		{'EXIT', _Pid, shutdown} ->
			io:format("[clock] manually terminated~n");
		{'EXIT', _Pid, _} ->
			io:format("[clock] something went wrong, 
				so I'll just restart~n"),
			restarter()
	end.

% main loop:
% responsable for calling all sensors to send their 
% readings every CLOCK_PERIOD_MS ms,
% also receives new sensors and add them to the 
% sensor list 'L'
loop(L) ->
	receive
		{new_sensor, A} ->
			loop([A|L])
	after ?CLOCK_PERIOD_MS ->
		io:format("[clock] tick~n"),
		NL = tick_all(L),
		loop(NL)
	end.

% send a 'tick' message to all processes in the inpu list,
% if an atom in the list represents a dead process the said 
% atom will be removed from the list
tick_all([H|L]) ->
	Pid = whereis(H),
	if 
		Pid =:= undefined -> tick_all(L);
		true -> Pid ! tick, [H|tick_all(L)]
	end;
tick_all([]) -> [].

% encapsulated message to add a new sensor 'S'
add_new_sensor(S) ->
	clock ! {new_sensor, S}.