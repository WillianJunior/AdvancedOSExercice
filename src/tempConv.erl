-module(tempConv).
-export([start/0, start_link/0, restarter/0, loop/1, basicCon/1]).

start() -> spawn(?MODULE, loop, [fun tempConv:basicCon/1]).

start_link() -> spawn(?MODULE, restarter, []).

restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, [fun tempConv:basicCon/1]),
	register(tempConv, Pid),
	receive
		{'EXIT', Pid, normal} ->
			io:format("temperature converter terminated normally~n");
		{'EXIT', Pid, shutdown} ->
			io:format("temperature converter manually terminated~n");
		{'EXIT', Pid, _} ->
			restarter()
	end.

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