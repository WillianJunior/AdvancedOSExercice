-module(main).
-export([start/0]).

start() ->
	PidTempConv = tempConv:startAndLink(),
	PidDisplay = display:startAndLink(),
	PidSensor1 = sensor:startAndLink(celsius, PidTempConv, PidDisplay),
	PidSensor2 = sensor:startAndLink(fahrenheit, PidTempConv, PidDisplay),
	_PidClock = clock:startAndLink(PidSensor1, PidSensor2),
	receive
	after 6000->
		loadNewFun(PidTempConv, fun(X)->X+1 end)
	end.

loadNewFun(Pid, F) -> Pid ! {loadNewConvFun, F}.