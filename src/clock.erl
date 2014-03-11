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
		{'EXIT', Pid, normal} ->
			io:format("clock terminated normally~n");
		{'EXIT', Pid, shutdown} ->
			io:format("clock manually terminated~n");
		{'EXIT', Pid, _} ->
			restarter()
	end.

loop(L) ->
	receive
		{new_sensor, A} ->
			loop([A|L])
	after 5000 ->
		io:format("tick~n"),
		tick_all(L)
	end,
	loop(L).

tick_all([H|L]) ->
	H ! tick,
	tick_all(L);
tick_all([]) -> [].

add_new_sensor(S) ->
	clock ! {new_sensor, S}.