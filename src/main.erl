-module(main).
-export([start/0]).

start() ->
	display:start_link(),
	tempConv:start(),
	clock:start(),
	sensor:start(celsiusSensor, celsius),
	sensor:start(fahrenheitSensor, fahrenheit),
	tempConv:add_new_fun(celsius, fun(X) -> X+1 end),
	tempConv:add_new_fun(fahrenheit, fun(X) -> X*2 end),
	clock:add_new_sensor(celsiusSensor),
	clock:add_new_sensor(fahrenheitSensor).

	
	%receive
	%after 6000->
	%	loadNewFun(tempConv, fun(X)->X+1 end)
	%end,
	%receive
	%after 5000->
	%	exit(whereis(tempConv), die)
	%end.