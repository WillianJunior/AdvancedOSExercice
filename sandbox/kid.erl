-module(kid).
-export([hi/0, die/0]).

hi () ->
	io:format("hello ~n"),
	receive 
		aliveee ->
			io:format("still alive ~n");
		dieee ->
			die(),
			exit(normal)
	end.


die () ->
	io:format("bye~n").