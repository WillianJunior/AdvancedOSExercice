-module(display).
-export([start/0, restarter/0, loop/0]).

% display spawner
start() -> spawn(?MODULE, restarter, []).

% the restarter makes sure that except when we explicitly
% killed the process, it will restart itself
restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, []),
	register(display, Pid),
	receive
		{'EXIT', _Pid, normal} ->
			io:format("[display] terminated normally~n");
		{'EXIT', _Pid, shutdown} ->
			io:format("[display] manually terminated~n");
		{'EXIT', _Pid, _} ->
			io:format("[display] something went wrong, 
				so I'll just restart~n"),
			restarter()
	end.

% main loop:
% responsable for receiving the temperature messages and 
% displaying them.
loop() ->
	receive
		{S, T} ->
			io:format("[display] temp from sensor 
				~s: ~w~n", [atom_to_list(S), T])
	end,
	loop().