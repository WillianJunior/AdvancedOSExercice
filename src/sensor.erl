-module(sensor).
-export([start/2, start_link/2, restarter/2, loop/2]).

start(S, F) -> 
	spawn(?MODULE, restarter, [S, F]).

start_link(S, F) ->
	spawn_link(?MODULE, restarter, [S, F]).

restarter(S, F) ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, [S, F]),
	register(S, Pid),
	receive
		{'EXIT', Pid, normal} ->
			io:format("sensor terminated normally~n");
		{'EXIT', Pid, shutdown} ->
			io:format("sensor manually terminated~n");
		{'EXIT', Pid, _} ->
			restarter(S, F)
	end.

loop(S, F) ->
	receive
		tick ->
			io:format("requesting temp conversion~n"),
			% get a random reading between 1 and 100
			T = random:uniform(100),
			tempConv:convert_temp(self(), F, T);
		{converted, T} ->
			io:format("converted. sending to be displayed~n"),
			display ! {S, T}
	end,
	loop(S, F).