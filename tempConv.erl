-module(tempConv).
-export([start/0]).

start() ->
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
	start().