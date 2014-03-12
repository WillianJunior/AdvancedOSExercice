-module(sensor).
-export([start/2, restarter/2, loop/2]).

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