-module(main).
-export([start/0]).

start() ->
	PidTempConv = spawn(fun tempConv:start/0),
	PidDisplay = spawn(fun display:start/0),
	PidSensor1 = spawn(fun() -> sensor:startC(PidTempConv, PidDisplay) end),
	PidSensor2 = spawn(fun() -> sensor:startF(PidTempConv, PidDisplay) end),
	PidClock = spawn(fun() -> clock:start(PidSensor1, PidSensor2) end),
	timer:start(),
	timer:sleep(10000).