-module(tempConv).
-export([start/0, start_link/0, restarter/0, loop/1, basicCon/1, get_fun/2]).

start() -> spawn(?MODULE, restarter, []).

start_link() -> spawn_link(?MODULE, restarter, []).

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

loop(Fs) ->
	receive
		{PidSender, convert, F, T} -> 	
			NewTFun = get_fun(Fs, F),
			NewT = NewTFun(T),
			io:format("converting: put the atom name~n"),
			PidSender ! {converted, NewT},
			loop(Fs);
		{loadNewConvFun, F} ->
			loop([F|Fs])
	end.

basicCon(T) -> T*2.

%F1 = tempConv:get_fun([{a,fun(X) -> X+1 end},{b,fun(Y) -> Y+2 end},{c,fun(X) -> X+3 end}], c), F1(1).

%fun(X) -> X+1 end
%fun(X) -> X+2 end
%fun(X) -> X+3 end

get_fun([{_F, Fun}|_], _F) -> Fun;
get_fun([{_, _}|Fs], F) -> get_fun(Fs, F);
get_fun([], _) -> [].

%loop(ConvFunc) ->
%	receive
%		{convertToCelsius, PidSender, Temp} -> 	
%			io:format("converting to celsius~n"),
%			ConvTemp = ConvFunc(Temp),
%			% return temperature to sender
%			PidSender ! {convertedCelsius, ConvTemp},
%			loop(ConvFunc);
%		{convertToFahrenheit, PidSender, Temp} ->
%			io:format("converting to fahrenheit~n"),
%			% return temperature to sender
%			PidSender ! {convertedFahrenheit, Temp},
%			loop(ConvFunc);
%		{loadNewConvFun, NewFun} ->
%			loop(NewFun)
%	end.