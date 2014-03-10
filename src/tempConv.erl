-module(tempConv).
-export([start/0, startAndLink/0, loop/1, basicCon/1]).

start() -> spawn(?MODULE, loop, [fun tempConv:basicCon/1]).

startAndLink() -> spawn(?MODULE, loop, [fun tempConv:basicCon/1]).

loop(ConvFunc) ->
	receive
		{convertToCelsius, PidSender, Temp} -> 	
			io:format("converting to celsius~n"),
			ConvTemp = ConvFunc(Temp),
			% return temperature to sender
			PidSender ! {convertedCelsius, ConvTemp},
			loop(ConvFunc);
		{convertToFahrenheit, PidSender, Temp} ->
			io:format("converting to fahrenheit~n"),
			% return temperature to sender
			PidSender ! {convertedFahrenheit, Temp},
			loop(ConvFunc);
		{loadNewConvFun, NewFun} ->
			loop(NewFun)
	end.

basicCon(T) -> T*2.