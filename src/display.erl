-module(display).
-behaviour (gen_event).

%-export([start/0, restarter/0, loop/0]).
-export([start_link/0]).
-export([init/1, handle_event/2, code_change/3, 
	handle_call/2, handle_info/2, terminate/2]).

%%% Client API
start_link() ->
	gen_event:start_link({local,output_man}),
	gen_event:add_handler(output_man, display, []).

%%% Server Functions
init(_Args) -> 
	{ok, []}.

handle_event({temp_reading, Sensor, Temp}, []) ->
	io:format("[display] temp from sensor 
				~s: ~w~n", [atom_to_list(Sensor), Temp]),
	{ok, []}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

% make it send to an error handler later...
handle_call(_Request, State) ->
	{ok, cant_handle, State}.

% make it send to an error handler later...
handle_info(_Info, State) ->
	{ok, State}.

% send terminate data to a logger later...
terminate(_Args, _State) ->
	io:format("[display] bye.").
