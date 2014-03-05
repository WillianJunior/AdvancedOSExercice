-module(clock).
-export([start/2]).

start(PidSensor1, PidSensor2) ->
	timer:start(),
	loop(PidSensor1, PidSensor2).

loop(PidSensor1, PidSensor2) ->
	receive
	after 5000 ->
		io:format("tick~n"),
		PidSensor1 ! tick,
		PidSensor2 ! tick
	end,
	loop(PidSensor1, PidSensor2).