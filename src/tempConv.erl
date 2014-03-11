-module(tempConv).
-export([start/0, start_link/0, restarter/0, loop/1, convert_temp/3, add_new_fun/2]).

start() -> spawn(?MODULE, restarter, []).

start_link() -> spawn_link(?MODULE, restarter, []).

restarter() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, loop, [[]]),
	register(tempConv, Pid),
	receive
		{'EXIT', Pid, normal} ->
			io:format("temperature converter terminated normally~n");
		{'EXIT', Pid, shutdown} ->
			io:format("temperature converter manually terminated~n");
		{'EXIT', Pid, _} ->
			restarter()
	end.

loop(Fs) ->
	receive
		{PidSender, convert, F, T} -> 	
			NewTFun = get_fun(Fs, F),
			NewT = NewTFun(T),
			io:format("converting: ~s~n", [atom_to_list(F)]),
			PidSender ! {converted, NewT},
			loop(Fs);
		{loadNewConvFun, F} ->
			loop([F|Fs])
	end.

get_fun([{_F, Fun}|_], _F) -> Fun;
get_fun([{_, _}|Fs], F) -> get_fun(Fs, F);
get_fun([], _) -> [].

convert_temp(Pid, F, T) ->
	tempConv ! {Pid, convert, F, T}.

add_new_fun(N, F) ->
	tempConv ! {loadNewConvFun, {N, F}}.

%fun(X) -> X+1 end
%fun(X) -> X+2 end
%fun(X) -> X+3 end