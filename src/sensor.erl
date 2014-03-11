-module(sensor).
-export([start/3, start_link/1, restarter/1, loop/1]).

start(celsius, PidTempConv, PidDisplay) -> 
	spawn(?MODULE, startC, [PidTempConv, PidDisplay]);
start(fahrenheit, PidTempConv, PidDisplay) -> 
	spawn(?MODULE, startF, [PidTempConv, PidDisplay]).

start_link(T) ->
	spawn_link(?MODULE, restarter, [T]).

restarter(T) ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, [T]),
	register(T, Pid),
	receive
		{'EXIT', Pid, normal} ->
			io:format("sensor terminated normally~n");
		{'EXIT', Pid, shutdown} ->
			io:format("sensor manually terminated~n");
		{'EXIT', Pid, _} ->
			restarter(T)
	end.

loop(celsiusSensor) ->
	receive
		tick ->
			io:format("requesting temp conversion~n"),
			tempConv ! {convertToCelsius, self(), 10};
		{convertedCelsius, Temp} ->
			io:format("converted to cesius. sending to be displayed~n"),
			display ! {temperatureCelsius, Temp}
	end,
	loop(celsiusSensor);
loop(fahrenheitSensor) -> 
	receive
		tick ->
			io:format("requesting temp conversion~n"),
			tempConv ! {convertToFahrenheit, self(), 2};
		{convertedFahrenheit, Temp} ->
			io:format("converted to fahrenheit. sending to be displayed~n"),
			display ! {temperatureFahrenheit, Temp}
	end,
	loop(fahrenheitSensor).