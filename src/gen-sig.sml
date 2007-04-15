(* gen/gen.sig -- signatures for random data generation
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

signature APPLICATIVE_RNG = 
sig 
(*<<*)
(*@ We begin with the raw random number generator.  The @code{new}
function generates a seed based on the current time.  The @code{range}
function produces random integers between those in the given pair, 
inclusive.  The generator is applicative, in the sense that it returns
the new state of the random number generator.
*)
type rand                                   (*@tindex rand*)
val new : unit -> rand                      (*@findex new*)
val range : int * int -> rand -> int * rand (*@findex range*)
(*>>*)
val split : rand -> rand * rand
end

signature GEN_TYPES =
sig 
type rand
(*<<*)
(*@ The generator for a type takes a random number stream
and produces a value of that type, along with the new state 
of the stream. *)
type 'a gen = rand -> 'a * rand             (*@tindex gen*)
type ('a, 'b) co = 'a -> 'b gen -> 'b gen   (*@tindex co*)
(*>>*)
end

signature GENERATOR' = 
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
val lift : 'a -> 'a gen                           (*@findex lift*)
val select : 'a vector -> 'a gen                  (*@findex select*)
val choose : 'a gen vector -> 'a gen              (*@findex choose*)
val choose' : (int * 'a gen) vector -> 'a gen     (*@findex choose'*)
(*@ The functions ending in @code{L} are the same, except they
operate on lists instead of vectors. *)
val selectL : 'a list -> 'a gen                   (*@findex selectL*)
val chooseL : 'a gen list -> 'a gen               (*@findex chooseL*)
val chooseL' : (int * 'a gen) list -> 'a gen      (*@findex chooseL'*)
(*@ Here are some basic map and filtering functions over generators. *)
val filter : ('a -> bool) -> 'a gen -> 'a gen     (*@findex filter*)
val zip : ('a gen * 'b gen) -> ('a * 'b) gen      (*@findex zip*)
val zip3 : ('a gen * 'b gen * 'c gen) ->          (*@findex zip3*)
           ('a * 'b * 'c) gen
val zip4 : ('a gen * 'b gen * 'c gen * 'd gen) -> (*@findex zip4*)
           ('a * 'b * 'c * 'd) gen
val map : ('a -> 'b) -> 'a gen -> 'b gen
val map2 : ('a * 'b -> 'c) -> ('a gen * 'b gen) ->(*@findex map*)
           'c gen
val map3 : ('a * 'b * 'c -> 'd) ->                (*@findex map2*)
           ('a gen * 'b gen * 'c gen) -> 'd gen
val map4 : ('a * 'b * 'c * 'd -> 'e) ->           (*@findex map4*)
           ('a gen * 'b gen * 'c gen * 'd gen) -> 
           'e gen

(*@ @code{flip} is just like flipping a fair coin.  With 
@code{flip'}, the coin is biased by the pair of integers given:
@code{flip' (3,5)} will choose @code{true} three-eights of the time,
and @code{false} five-eights. *)
val flip : bool gen                               (*@findex flip*)
val flip' : int * int -> bool gen                 (*@findex flip'*)

(*@ These produce lists or optional values by consulting the
boolean generator about when to produce the nil list or @code{NONE}. *)
val list : bool gen -> 'a gen -> 'a list gen      (*@findex list*)
val option : bool gen -> 'a gen -> 'a option gen  (*@findex option*)
(*@ The following function produces any kind of sequential 
collection type, you just provide the @code{tabulate} function 
as the first parameter.  The integer generator then determines 
how many elements the collection will have. *)
val vector : (int * (int -> 'a) -> 'b) ->         (*@findex vector*)
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

val variant : (int,'b) co                         (*@findex variant*)
val arrow : ('a, 'b) co * 'b gen -> ('a -> 'b) gen(*@findex arrow*)
val cobool : (bool, 'b) co                        (*@findex cobool*)
val colist : ('a, 'b) co -> ('a list, 'b) co      (*@findex colist*)
val coopt : ('a, 'b) co -> ('a option, 'b) co     (*@findex coopt*)

(*@ These turn generators into a stream of values.  You can 
limit them by a given integer, or just use the default maximum
number of values from the @code{Settings}.  *)
type stream                                       (*@tindex stream*)
val start : rand -> stream                        (*@findex start*)
val limit' : int -> 'a gen -> ('a,stream) reader  (*@findex limit'*)
val limit : 'a gen -> ('a,stream) reader          (*@findex limit*)
(*>>*)
end

signature TEXT_GENERATOR' =
sig
    include GENERATOR'
(*<<*)
(*@ 
@section Basis types
In addition to the general combinators, practically all of the
SML Basis types have associated generators in sub-structures.  The
following generators can be instantiated for whatever character and
string types your implementation provides, such as 
@code{Gen.WideText.charByType}.  For the default character and string
types, however, these are found in the top-level of the @code{Gen}
structure. *)
type char                                       (*@tindex char*)
type string                                     (*@tindex string*)
type substring                                  (*@tindex substring*)
val char : char gen                             (*@findex char*)
val charRange : char * char -> char gen         (*@findex charRange*)
val charFrom : string -> char gen               (*@findex charFrom*)
val charByType : (char -> bool) -> char gen     (*@findex charByType*)
val string : (int gen * char gen) -> string gen (*@findex string*)
val substring : string gen -> substring gen     (*@findex substring*)
val cochar : (char, 'b) co                      (*@findex cochar*)
val costring : (string, 'b) co                  (*@findex costring*)
val cosubstring : (substring, 'b) co            (*@findex cosubstring*)
(*>>*)
end

signature TEXT_GENERATOR = TEXT_GENERATOR'
  where type char = char
    and type string = string
    and type substring = substring

signature INT_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@ The functions in @code{Gen.Int} (and @code{Gen.Int32}, @code{Gen.IntInf}, 
etc.) generate integers in various ranges.  They can easily be instantiated 
for whatever integer types your implementation provides.  They are biased
so that zero, @code{maxInt}, and @code{minInt} (if they exist) are
generated much more often than other integers. *)
eqtype int                              (*@tindex int*)
val int : int gen                       (*@findex int*)
val pos : int gen                       (*@findex pos*)
val neg : int gen                       (*@findex neg*)
val nonpos : int gen                    (*@findex nonpos*)
val nonneg : int gen                    (*@findex nonneg*)
val coint : (int, 'b) co                (*@findex coint*)
(*>>*)
end

signature WORD_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@ The functions generating unsigned words are in structures such as
@code{Gen.Word}, @code{Gen.Word8}, @code{Gen,Word32}, etc., depending
on your implementation. *)
eqtype word                             (*@tindex word*)
val word : word gen                     (*@findex word*)
val coword : (word, 'b) co              (*@findex coword*)
(*>>*)
end

signature REAL_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@ These are in @code{Gen.Real} structure.  Currently, real numbers are 
generated from strings of (decimal) digits, rather than from bits.  
So some valid reals will never be generated. This may not be sufficient 
for testing numerical code. *)
type real                               (*@tindex real*)
val real : real gen                     (*@findex real*)
val frac : real gen                     (*@findex frac*)
val pos : real gen                      (*@findex pos*)
val neg : real gen                      (*@findex neg*)
val nonpos : real gen                   (*@findex nonpos*)
val nonneg : real gen                   (*@findex nonneg*)
val finite : real gen                   (*@findex finite*)
(*>>*)
end

signature DATE_TIME_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@ Generate dates and times from @code{Gen.DateTime}.  The 
@code{dateFromYear} function uses the given generator to produce
the year, but then it comes up with a month, day, hour, minute, 
and second itself.  A few days are more likely than others because
we do not bother to generate the correct number of days based on the
month.  This makes May 1st more likely than May 2nd, because it could 
also have been generated as April 31st.  (The Basis @code{Date.date} 
normalizes the dates though, so you will never see April 31st.) *)
val weekday : Date.weekday gen              (*@findex weekday*)
val month : Date.month gen                  (*@findex month*)
val dateFromYear : int gen -> Date.date gen (*@findex dateFromYear*)
val time : Time.time gen                    (*@findex time*)
(*>>*)
val dateFromUTC : Date.date gen  (* broken? *)
end
