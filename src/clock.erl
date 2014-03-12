-module(clock).
-export([start/0, start_link/0, restarter/0, loop/1, add_new_sensor/1]).

start() ->
	spawn(?MODULE, restarter, []).

start_link() ->
	spawn_link(?MODULE, restarter, []).

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
			io:format("[clock] something went wrong, so I'll just restart~n"),
			restarter()
	end.

loop(L) ->
	receive
		{new_sensor, A} ->
			loop([A|L])
	after 5000 ->
		io:format("[clock] tick~n"),
		NL = tick_all(L),
		loop(NL)
	end.

tick_all([H|L]) ->
	Pid = whereis(H),
	if 
		Pid =:= undefined -> tick_all(L);
		true -> Pid ! tick, [H|tick_all(L)]
	end;
tick_all([]) -> [].

add_new_sensor(S) ->
	clock ! {new_sensor, S}.