-module(main).
-export([start/0]).

start() ->
	display:start(),
	tempConv:start(),
	receive
	after 1000->
		tempConv:add_new_fun(celsius, fun(X) -> X+1 end),
		tempConv:add_new_fun(fahrenheit, fun(X) -> X*2 end),
	end.
	%sensor:start(fahrenheitSensor),
	%clock:start(),
	%sensor:start(celsiusSensor),
	%clock:add_new_sensor(celsiusSensor).
	%clock:add_new_sensor(fahrenheitSensor),
	%supervisor:start(),

	%loop(),

	%receive
	%after 6000->
	%	loadNewFun(tempConv, fun(X)->X+1 end)
	%end,
	%receive
	%after 5000->
	%	exit(whereis(tempConv), die)
	%end.

loop() ->
	process_flag(trap_exit, true),
	receive
		{'EXIT', Pid, normal} ->
			io:format("clock terminated normally~n"),
			exit(shutdown);
		{'EXIT', Pid, shutdown} ->
			io:format("clock manually terminated~n");
		{'EXIT', Pid, _} ->
			loop()
	end.

loadNewFun(A, F) -> A ! {loadNewConvFun, F}.