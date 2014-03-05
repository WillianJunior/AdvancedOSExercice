-module(test).
-export([append/2, makeAndKill/0]).

append([H|T],L) -> [H|append(T,L)];
append([],L) -> [L]. 

makeAndKill () -> 
	Pid1 = spawn(fun kid:hi/0),
	io:format("spawned~n"),
	%exit(Pid1,normal),
	io:format("msg~n"),
	%Pid1 ! aliveee,
	timer:start(),
	timer:send_after(1000, Pid1, aliveee),
	io:format("killing~n"),
	%Pid1 ! dieee,
	io:format("killed~n"),
	%Pid1 ! aliveee,
	timer:sleep(4000).