-module(sensor).
-export([start/3, startC/2, startF/2]).

start(celsius, PidTempConv, PidDisplay) -> 
	spawn(?MODULE, startC, [PidTempConv, PidDisplay]);
start(fahrenheit, PidTempConv, PidDisplay) -> 
	spawn(?MODULE, startF, [PidTempConv, PidDisplay]).

startC(PidTempConv, PidDisplay) ->
	receive
		tick ->
			io:format("requesting temp conversion~n"),
			PidTempConv ! {convertToCelsius, self(), 1};
		{convertedCelsius, Temp} ->
			io:format("converted to cesius. sending to be displayed~n"),
			PidDisplay ! {temperatureCelsius, Temp}
	end,
	startC(PidTempConv, PidDisplay).

startF(PidTempConv, PidDisplay) ->
	receive
		tick ->
			io:format("requesting temp conversion~n"),
			PidTempConv ! {convertToFahrenheit, self(), 2};
		{convertedFahrenheit, Temp} ->
			io:format("converted to fahrenheit. sending to be displayed~n"),
			PidDisplay ! {temperatureFahrenheit, Temp}
	end,
	startF(PidTempConv, PidDisplay).