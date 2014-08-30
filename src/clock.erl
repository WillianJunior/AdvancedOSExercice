-module(clock).
-behaviour (gen_fsm).

-define (CLOCK_PERIOD_MS, 3000).

-export([start_link/0]).
-export([add_new_sensor/1]).
-export([init/1, main_state/2]).

%% Client API
start_link() ->
	gen_fsm:start_link({local, clock}, clock, [], []).

%%% Server Functions
init(_Arg) ->
	gen_fsm:start_timer(?CLOCK_PERIOD_MS, []),
	{ok, main_state, []}.

%% Async call
add_new_sensor(Sensor) ->
	gen_fsm:send_event(clock, {new_sensor, Sensor}).

%% States
main_state(Event, Sensors) ->
	case Event of
		{new_sensor, Sensor} ->
			{next_state, main_state, [Sensor|Sensors]};
		{timeout, _Ref, _Msg} ->
			tick_all(Sensors),
			gen_fsm:start_timer(?CLOCK_PERIOD_MS, []),
			{next_state, main_state, Sensors}
	end.

% send a 'tick' message to all processes in the inpu list,
% if an atom in the list represents a dead process the said 
% atom will be removed from the list
tick_all([H|L]) ->
	Pid = whereis(H),
	if 
		Pid =:= undefined -> tick_all(L);
		true -> Pid ! tick, [H|tick_all(L)]
	end;
tick_all([]) -> [].