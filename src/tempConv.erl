-module(tempConv).
-behaviour (gen_server).

-export([start_link/0]).
-export([request_conversion/2, add_new_fun/2]).
-export([init/1, code_change/3, terminate/2, handle_info/2, 
	handle_call/3, handle_cast/2]).

%%% Client API
start_link() ->
	gen_server:start_link({local, tempConv}, tempConv, [], []).

%% Sync Call
request_conversion(Function, Temp) ->
	gen_server:call(tempConv, {request_conversion, Function, Temp}).

%% Async Call
add_new_fun(Function_Ref, Function) ->
	gen_server:cast(tempConv, {add_new_fun, Function_Ref, Function}).

%%% Server Functions
init(_Args) ->
	{ok, []}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

% send terminate data to a logger later...
terminate(_Reason, _State) -> ok.

%% handlers
% currently not needed. send event to a logger later
handle_info(_Info, State) ->
	{noreply, State}.

handle_call({request_conversion, Function, Temp}, _From, Functions) ->
	New_T_Fun = get_fun(Functions, Function),
	New_T = New_T_Fun(Temp),
	io:format("[converter] converting: 
		~s~n", [atom_to_list(Function)]),
	{reply, New_T, Functions}.

handle_cast({add_new_fun, Function_Ref, Function}, Functions) ->
	{noreply, [{Function_Ref, Function}|Functions]}.

%%Private function
% return the function mached by its atom name 'F'
get_fun([{_F, Fun}|_], _F) -> Fun;
get_fun([{_, _}|Fs], F) -> get_fun(Fs, F);
get_fun([], _) -> [].