-module(sensor).
-behaviour (gen_server).
%-export([start/2, restarter/2, loop/2]).
-export([start_link/2]).
-export([request_reading/1]).
-export([init/1, handle_cast/2]).


%%% Client API
start_link(Sensor_Ref, Function_Ref) ->
	 gen_server:start_link({local, Sensor_Ref}, sensor, [Sensor_Ref, Function_Ref], []).

%% Async call
request_reading(Sensor_Ref) ->
	gen_server:cast(Sensor_Ref, request_reading).

%%% Server Functions
init([Sensor_Ref, Function_Ref]) ->
	{ok, [Sensor_Ref, Function_Ref]}.

handle_cast(request_reading, [Sensor_Ref, Function_Ref]) ->
	io:format("[sensor ~s] requesting temp 
		conversion~n", [atom_to_list(Sensor_Ref)]),
	% get a random reading between 1 and 100
	T = random:uniform(100),
	T_New = tempConv:request_conversion(Function_Ref, T),
	io:format("[sensor ~s] temp converted. 
		sending to be displayed~n", [atom_to_list(Sensor_Ref)]),
	display ! {Sensor_Ref, T_New},
	{noreply, [Sensor_Ref, Function_Ref]}.









% sensor spawner
start(S, F) -> 
	spawn(?MODULE, restarter, [S, F]).

% the restarter makes sure that except when we explicitly
% killed the process, it will restart itself
restarter(S, F) ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, [S, F]),
	register(S, Pid),
	receive
		{'EXIT', _Pid, normal} ->
			io:format("[sensor ~s] terminated normally~n", 
				[atom_to_list(S)]);
		{'EXIT', _Pid, shutdown} ->
			io:format("[sensor ~s] manually terminated~n", 
				[atom_to_list(S)]);
		{'EXIT', _Pid, _} ->
			io:format("[sensor ~s] something went wrong, 
				so I'll just restart~n", [atom_to_list(S)]),
			restarter(S, F)
	end.

% main loop:
% responsable for requesting a temperature conversion every 
% 'tick' message and sending the output to 'display'
loop(S, F) ->
	receive
		tick ->
			io:format("[sensor ~s] requesting temp 
				conversion~n", [atom_to_list(S)]),
			% get a random reading between 1 and 100
			T = random:uniform(100),
			tempConv:convert_temp(self(), F, T);
		{converted, T} ->
			io:format("[sensor ~s] temp converted. 
				sending to be displayed~n", [atom_to_list(S)]),
			display ! {S, T}
	end,
	loop(S, F).