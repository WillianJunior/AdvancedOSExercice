-module(display).
-export([start/0]).

start() ->
	receive
		{temperatureCelsius, Temp} ->
			io:format("printing temp in celsius~n");
		{temperatureFahrenheit, Temp} ->
			io:format("printing temp in fahrenheit~n")
	end,
	start().