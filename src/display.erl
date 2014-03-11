-module(display).
-export([start/0, start_link/0, restarter/0, loop/0]).

start() -> spawn(?MODULE, loop, []).

start_link() -> spawn_link(?MODULE, restarter, []).

restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, []),
	register(display, Pid),
	receive
		{'EXIT', Pid, normal} ->
			io:format("display terminated normally~n");
		{'EXIT', Pid, shutdown} ->
			io:format("display manually terminated~n");
		{'EXIT', Pid, _} ->
			restarter()
	end.

loop() ->
	receive
		{temperatureCelsius, Temp} ->
			io:format("printing temp in celsius: ~w~n", [Temp]);
		{temperatureFahrenheit, Temp} ->
			io:format("printing temp in fahrenheit: ~w~n", [Temp])
	end,
	loop().