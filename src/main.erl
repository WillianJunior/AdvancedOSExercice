-module(main).
-export([start/0]).

start() ->
	% start all processes
	display:start(),
	tempConv:start(),
	clock:start(),
	sensor:start(celsiusSensor, celsius),
	sensor:start(fahrenheitSensor, fahrenheit),

	% add the functions and sensors
	tempConv:add_new_fun(celsius, fun(X) -> X+1 end),
	tempConv:add_new_fun(fahrenheit, fun(X) -> X*2 end),
	clock:add_new_sensor(celsiusSensor),
	clock:add_new_sensor(fahrenheitSensor).