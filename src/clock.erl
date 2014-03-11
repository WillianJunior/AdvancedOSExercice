-module(clock).
-export([start/0, start_link/0, restarter/0, loop/0]).

start() ->
	spawn(?MODULE, restarter, []).

start_link() ->
	spawn_link(?MODULE, restarter, []).

restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, []),
	register(clock, Pid),
	receive
		{'EXIT', Pid, normal} ->
			io:format("clock terminated normally~n");
		{'EXIT', Pid, shutdown} ->
			io:format("clock manually terminated~n");
		{'EXIT', Pid, _} ->
			restarter()
	end.

loop() ->
	receive
	after 5000 ->
		io:format("tick~n"),
		celsiusSensor ! tick,
		fahrenheitSensor ! tick
	end,
	loop().