signature PREGEN_SIG =
sig
include GEN_TYPES
val new : unit -> rand
val range : int * int -> rand -> int * rand
type ('a,'b) reader = 'b -> ('a * 'b) option
(*<<*)
(*@
@section Random-value combinators
@code{lift v} is a generator that always produces the given value.
@code{select} picks uniform randomly from the values in the vector,
while @code{choose} picks uniform randomly from the @i{generators}
in the vector, to produce a value.  For example:
@example
   Gen.choose #[Gen.lift 42, Gen.Int.int]
@end example
will return the number 42 with 50% probability, and a random integer
otherwise (but recall that @code{Gen.Int.int} is biased toward zero and
the extrema).  The primed version pairs each generator with an integer
weight to bias the choice (making it non-uniform). *)
(*@findex lift*)
val lift : 'a -> 'a gen
(*@findex select*)
val select : 'a vector -> 'a gen
(*@findex choose*)
val choose : 'a gen vector -> 'a gen
(*@findex choose'*)
val choose' : (int * 'a gen) vector -> 'a gen
(*@ The functions ending in @code{L} are the same, except they
operate on lists instead of vectors. *)
(*@findex selectL*)
val selectL : 'a list -> 'a gen
(*@findex chooseL*)
val chooseL : 'a gen list -> 'a gen
(*@findex chooseL'*)
val chooseL' : (int * 'a gen) list -> 'a gen
(*@ Here are some basic map and filtering functions over generators. *)
(*@findex filter*)
val filter : ('a -> bool) -> 'a gen -> 'a gen
(*@findex zip*)
val zip : ('a gen * 'b gen) -> ('a * 'b) gen
(*@findex zip3*)
val zip3 : ('a gen * 'b gen * 'c gen) ->
           ('a * 'b * 'c) gen
(*@findex zip4*)
val zip4 : ('a gen * 'b gen * 'c gen * 'd gen) ->
           ('a * 'b * 'c * 'd) gen
(*@findex map*)
val map : ('a -> 'b) -> 'a gen -> 'b gen
(*@findex map2*)
val map2 : ('a * 'b -> 'c) -> ('a gen * 'b gen) ->
           'c gen
(*@findex map3*)
val map3 : ('a * 'b * 'c -> 'd) ->
           ('a gen * 'b gen * 'c gen) -> 'd gen
(*@findex map4*)
val map4 : ('a * 'b * 'c * 'd -> 'e) ->
           ('a gen * 'b gen * 'c gen * 'd gen) ->
           'e gen

(*@ @code{flip} is just like flipping a fair coin.  With
@code{flip'}, the coin is biased by the pair of integers given:
@code{flip' (3,5)} will choose @code{true} three-eights of the time,
and @code{false} five-eights. *)
(*@findex flip*)
val flip : bool gen
(*@findex flip'*)
val flip' : int * int -> bool gen

(*@ These produce lists or optional values by consulting the
boolean generator about when to produce the nil list or @code{NONE}. *)
(*@findex list*)
val list : bool gen -> 'a gen -> 'a list gen
(*@findex option*)
val option : bool gen -> 'a gen -> 'a option gen
(*@ The following function produces any kind of sequential
collection type, you just provide the @code{tabulate} function
as the first parameter.  The integer generator then determines
how many elements the collection will have. *)
(*@findex vector*)
val vector : (int * (int -> 'a) -> 'b) ->
             int gen * 'a gen -> 'b gen
(*@ Here is an example, showing how we can generate strings
with @code{vector}:
@example
    Gen.vector CharVector.tabulate
               (Gen.range(6,10), Gen.select #[#"a", #"b", #"c"])
@end example
Here is a sample of the strings it generated in one test:
@example
 @print{} "abbacccbbb" : CharVector.vector
 @print{} "bccbaabacb" : CharVector.vector
 @print{} "aacbbbaba" : CharVector.vector
 @print{} "aabbaca" : CharVector.vector
 @print{} "acaacbb" : CharVector.vector
 @print{} "cbbbccab" : CharVector.vector
 @print{} "bbcaccca" : CharVector.vector
@end example
*)

(*@ Here are some basic co-generators.
@code{variant} takes a small non-negative @code{int} and performs
simple unary branching.  @code{variant'} is similar but
takes an additional bound to save the last split.
@code{variant'} is the building block of all other built-in co-generators.

Note: @code{variant v} is equivalent to @code{variant' (v+2, v)} for small @code{v}.
@code{variant' (b, v)} raises @code{Subscript} if @code{v < 0} or @code{v >= b}.
*)

(*@findex variant*)
val variant : (int,'b) co
(*@findex variant'*)
val variant' : (int*int,'b) co
(*@findex arrow*)
val arrow : ('a, 'b) co * 'b gen -> ('a -> 'b) gen
(*@findex cobool*)
val cobool : (bool, 'b) co
(*@findex colist*)
val colist : ('a, 'b) co -> ('a list, 'b) co
(*@findex coopt*)
val coopt : ('a, 'b) co -> ('a option, 'b) co

(*@ These turn generators into a stream of values.  You can
limit them by a given integer, or just use the default maximum
number of values from the @code{Settings}.  *)
(*@tindex stream*)
type stream
(*@findex start*)
val start : rand -> stream
(*@findex limit'*)
val limit' : int -> 'a gen -> ('a,stream) reader
(*@findex limit*)
val limit : 'a gen -> ('a,stream) reader
(*>>*)
end

