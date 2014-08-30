-module(tempConv).
-behaviour (gen_server).
%-export([start/0, restarter/0, loop/1, convert_temp/3, add_new_fun/2]).
-export([start_link/0]).
-export([request_conversion/2, add_new_fun/2]).
-export([init/1, handle_call/3, handle_cast/2]).

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

handle_call({request_conversion, Function, Temp}, _From, Functions) ->
	io:format("here"),
	New_T_Fun = get_fun(Functions, Function),
	New_T = New_T_Fun(Temp),
	io:format("[converter] converting: 
		~s~n", [atom_to_list(Function)]),
	{reply, New_T, Functions}.

handle_cast({add_new_fun, Function_Ref, Function}, Functions) ->
	{noreply, [{Function_Ref, Function}|Functions]}.










% converter spawner
start() -> spawn(?MODULE, restarter, []).

% the restarter makes sure that except when we explicitly
% killed the process, it will restart itself
restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, [[]]),
	register(tempConv, Pid),
	receive
		{'EXIT', _Pid, normal} ->
			io:format("[converter] terminated normally~n");
		{'EXIT', _Pid, shutdown} ->
			io:format("[converter] manually terminated~n");
		{'EXIT', _Pid, _} ->
			io:format("[converter] something went wrong, 
				so I'll just restart~n"),
			restarter()
	end.

% main loop:
% responsable for receiving convert requests and responding
% with the converted temperature given the requested function,
% (that is inside its function list 'Fs'),
% can also receive new functions and add them to 'Fs'
loop(Fs) ->
	receive
		{PidSender, convert, F, T} -> 	
			NewTFun = get_fun(Fs, F),
			NewT = NewTFun(T),
			io:format("[converter] converting: 
				~s~n", [atom_to_list(F)]),
			PidSender ! {converted, NewT},
			loop(Fs);
		{loadNewConvFun, F} ->
			loop([F|Fs])
	end.

% return the function mached by its atom name 'F'
get_fun([{_F, Fun}|_], _F) -> Fun;
get_fun([{_, _}|Fs], F) -> get_fun(Fs, F);
get_fun([], _) -> [].

% encapsulated message to convert the temperature 'T' 
% using function 'F' and return the result to process 'Pid'
convert_temp(Pid, F, T) ->
	tempConv ! {Pid, convert, F, T}.

% encapsulated message to add a new function 'F' with 
% the atom name 'N'
%add_new_fun(N, F) ->
%	tempConv ! {loadNewConvFun, {N, F}}.