-module(main).
-export([start/0]).

start() ->
	PidTempConv = tempConv:start(),
	PidDisplay = display:start(),
	PidSensor1 = sensor:start(celsius, PidTempConv, PidDisplay),
	PidSensor2 = sensor:start(fahrenheit, PidTempConv, PidDisplay),
	_PidClock = clock:start(PidSensor1, PidSensor2).