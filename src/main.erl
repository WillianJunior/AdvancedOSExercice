-module(main).
-export([start/0]).

start() ->
	% start all processes
	display:start(),
	tempConv:start(),
	clock:start(),
	sensor:start(celsiusSensor, fahrenheit2celsius),
	sensor:start(fahrenheitSensor, celsius2fahrenheit),

	% add the functions and sensors
	tempConv:add_new_fun(fahrenheit2celsius, fun(X) -> (X-32)*5/9 end),
	tempConv:add_new_fun(celsius2fahrenheit, fun(X) -> (X*9/5)+32 end),
	clock:add_new_sensor(celsiusSensor),
	clock:add_new_sensor(fahrenheitSensor).