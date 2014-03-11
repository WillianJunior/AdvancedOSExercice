-module(main).
-export([start/0]).

start() ->
	PidTempConv = tempConv:start_link(),
	PidDisplay = display:start_link(),
	PidSensor1 = sensor:start_link(celsiusSensor),
	PidSensor2 = sensor:start_link(fahrenheitSensor),
	_PidClock = clock:start_link(),
	receive
	after 6000->
		loadNewFun(tempConv, fun(X)->X+1 end)
	end,
	receive
	after 5000->
		exit(whereis(tempConv), die)
	end.

loadNewFun(A, F) -> A ! {loadNewConvFun, F}.