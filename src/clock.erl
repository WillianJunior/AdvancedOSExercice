-module(clock).
-behaviour (gen_fsm).

-define (CLOCK_PERIOD_MS, 3000).

-export([start_link/0]).
-export([add_new_sensor/1]).
-export([init/1, main_state/2, code_change/4, terminate/3, 
	handle_event/3, handle_info/3, handle_sync_event/4]).

%% Client API
start_link() ->
	gen_fsm:start_link({local, clock}, clock, [], []).

%%% Server Functions
init(_Arg) ->
	gen_fsm:start_timer(?CLOCK_PERIOD_MS, []),
	{ok, main_state, []}.

code_change(_OldVsn, State, Data, _Extra) ->
	{ok, State, Data}.

% send terminate data to a logger later...
terminate(_Reason, _State, _Data) -> ok.

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

%% handlers
% currently not needed. send event to a logger later
handle_event(_Event, State, Data) ->
	{State, State, Data}.

% currently not needed. send event to a logger later
handle_info(_Info, State, Data) ->
	{State, State, Data}.

% currently not needed. send event to a logger later
handle_sync_event(_Event, _From, State, Data) ->
	{State, State, Data}.

%% Private Function
% send a 'tick' message to all processes in the inpu list,
% if an atom in the list represents a dead process the said 
% atom will be removed from the list
tick_all([H|L]) ->
	Exists = lists:member(H, registered()),
	if 
		Exists -> sensor:request_reading(H), tick_all(L);
		true -> tick_all(L)
	end;
tick_all([]) -> [].