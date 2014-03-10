-module(tempConv).
-export([start/0, loop/0]).

start() -> spawn(?MODULE, loop, []).

loop() ->
	receive
		{convertToCelsius, PidSender, Temp} -> 	
			io:format("converting to celsius~n"),
			% return temperature to sender
			PidSender ! {convertedCelsius, Temp};
		{convertToFahrenheit, PidSender, Temp} ->
			io:format("converting to fahrenheit~n"),
			% return temperature to sender
			PidSender ! {convertedFahrenheit, Temp}
	end,
	loop().