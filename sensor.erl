-module(sensor).
-export([startC/2, startF/2]).

startC(PidTempConv, PidDisplay) ->
	receive
		test ->
			io:format("test~n");
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
			PidTempConv ! {convertToFahrenheit, self(), 1};
		{convertedFahrenheit, Temp} ->
			io:format("converted to fahrenheit. sending to be displayed~n"),
			PidDisplay ! {temperatureFahrenheit, Temp}
	end,
	startF(PidTempConv, PidDisplay).