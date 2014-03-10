-module(display).
-export([start/0, loop/0]).

start() -> spawn(?MODULE, loop, []).

loop() ->
	receive
		{temperatureCelsius, Temp} ->
			io:format("printing temp in celsius: ~w~n", [Temp]);
		{temperatureFahrenheit, Temp} ->
			io:format("printing temp in fahrenheit: ~w~n", [Temp])
	end,
	loop().