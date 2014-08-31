-module(sensor).
-behaviour (gen_server).
%-export([start/2, restarter/2, loop/2]).
-export([start_link/2]).
-export([request_reading/1]).
-export([init/1, code_change/3, terminate/2, handle_cast/2
	, handle_call/3, handle_info/2]).


%%% Client API
start_link(Sensor_Ref, Function_Ref) ->
	 gen_server:start_link({local, Sensor_Ref}, sensor, [Sensor_Ref, Function_Ref], []).

%% Async call
request_reading(Sensor_Ref) ->
	gen_server:cast(Sensor_Ref, request_reading).

%%% Server Functions
init([Sensor_Ref, Function_Ref]) ->
	{ok, [Sensor_Ref, Function_Ref]}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

% send terminate data to a logger later...
terminate(_Reason, _State) -> ok.

%% handlers
% currently not needed. send event to a logger later
handle_call(_Request, _From, State) ->
	{noreply, State}.

% currently not needed. send event to a logger later
handle_info(_Info, State) ->
	{noreply, State}.

% Async call
handle_cast(request_reading, [Sensor_Ref, Function_Ref]) ->
	io:format("[sensor ~s] requesting temp 
		conversion~n", [atom_to_list(Sensor_Ref)]),
	% get a random reading between 1 and 100
	T = random:uniform(100),
	T_New = tempConv:request_conversion(Function_Ref, T),
	io:format("[sensor ~s] temp converted. 
		sending to be displayed~n", [atom_to_list(Sensor_Ref)]),
	gen_event:notify(output_man, {temp_reading, Sensor_Ref, T_New}),
	{noreply, [Sensor_Ref, Function_Ref]}.