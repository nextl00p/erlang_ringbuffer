-module(erlang_ringbuffer).

%% API exports
-export([new/1, add/2, getFirst/1, getAll/1]).

%%====================================================================
%% API functions
%%====================================================================
-record(ringbuffer, {
	max :: non_neg_integer(),
	cur :: non_neg_integer(),
	q :: queue:queue()
}).
	
-opaque ringbuffer() :: #ringbuffer{}.

-export_type([ringbuffer/0]).

new(Size) ->
	#ringbuffer{max = Size, cur = 0, q = queue:new()}.

add(Item, Buf) ->
	%We have to fallback to tuples to circumvent 'illegal pattern'
	case Buf of
		% Maximum reached?
		{ringbuffer, Max, Max, _} -> 
			{_, RemovedLast} = queue:out(Buf#ringbuffer.q),
			Buf#ringbuffer{q = queue:in(Item, RemovedLast)};
		% no, we can just add
		{ringbuffer, _Max, _Cur, _} ->
			Buf#ringbuffer{cur = Buf#ringbuffer.cur + 1,
			q = queue:in(Item, Buf#ringbuffer.q) }
	end.

getFirst(Buf) ->
	queue:get_r(Buf#ringbuffer.q).

getAll(Buf) ->
	queue:to_list(Buf#ringbuffer.q).


%%====================================================================
%% Internal functions
%%====================================================================
