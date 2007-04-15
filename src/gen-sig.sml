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
(*@findex GENERATOR signature*)
(*@ We begin with the raw random number generator.  The @code{new}
function generates a seed based on the current time.  The @code{range}
function produces random integers between those in the given pair,
inclusive.  The generator is applicative, in the sense that it returns
the new state of the random number generator.
*)
(*@tindex rand*)
type rand
(*@findex new*)
val new : unit -> rand
(*@findex range*)
val range : int * int -> rand -> int * rand
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
(*@tindex gen*)
type 'a gen = rand -> 'a * rand
(*@tindex co*)
type ('a, 'b) co = 'a -> 'b gen -> 'b gen
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

(*@findex variant*)
val variant : (int,'b) co
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
(*@tindex char*)        
type char                                       
(*@tindex string*)      
type string                                     
(*@tindex substring*)   
type substring                                  
(*@findex char*)        
val char : char gen                             
(*@findex charRange*)   
val charRange : char * char -> char gen         
(*@findex charFrom*)    
val charFrom : string -> char gen               
(*@findex charByType*)  
val charByType : (char -> bool) -> char gen     
(*@findex string*)      
val string : (int gen * char gen) -> string gen 
(*@findex substring*)   
val substring : string gen -> substring gen     
(*@findex cochar*)      
val cochar : (char, 'b) co                      
(*@findex costring*)    
val costring : (string, 'b) co                  
(*@findex cosubstring*) 
val cosubstring : (substring, 'b) co            
(*>>*)
end

signature TEXT_GENERATOR = TEXT_GENERATOR'
  where type char = char
    and type string = string
    and type substring = substring

signature INT_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@findex Int structures *)
(*@ The functions in @code{Gen.Int} (and @code{Gen.Int32}, @code{Gen.IntInf},
etc.) generate integers in various ranges.  They can easily be instantiated
for whatever integer types your implementation provides.  They are biased
so that zero, @code{maxInt}, and @code{minInt} (if they exist) are
generated much more often than other integers. *)
(*@tindex int*)
eqtype int                              
(*@findex int*)
val int : int gen                       
(*@findex pos*)
val pos : int gen                       
(*@findex neg*)
val neg : int gen                       
(*@findex nonpos*)
val nonpos : int gen                    
(*@findex nonneg*)
val nonneg : int gen                    
(*@findex coint*)
val coint : (int, 'b) co                
(*>>*)
end

signature WORD_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@findex Word structures *)
(*@ The functions generating unsigned words are in structures such as
@code{Gen.Word}, @code{Gen.Word8}, @code{Gen,Word32}, etc., depending
on your implementation. *)
(*@tindex word*)
eqtype word                             
(*@findex word*)
val word : word gen                     
(*@findex coword*)
val coword : (word, 'b) co              
(*>>*)
end

signature REAL_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@findex Real structure *)
(*@ These are in @code{Gen.Real} structure.  Currently, real numbers are
generated from strings of (decimal) digits, rather than from bits.
So some valid reals will never be generated. This may not be sufficient
for testing numerical code. *)
(*@tindex real*)
type real                               
(*@findex real*)
val real : real gen                     
(*@findex frac*)
val frac : real gen                     
(*@findex pos*)
val pos : real gen                      
(*@findex neg*)
val neg : real gen                      
(*@findex nonpos*)
val nonpos : real gen                   
(*@findex nonneg*)
val nonneg : real gen                   
(*@findex finite*)
val finite : real gen                   
(*>>*)
end

signature DATE_TIME_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@findex DateTime structure *)
(*@ Generate dates and times from @code{Gen.DateTime}.  The
@code{dateFromYear} function uses the given generator to produce
the year, but then it comes up with a month, day, hour, minute,
and second itself.  A few days are more likely than others because
we do not bother to generate the correct number of days based on the
month.  This makes May 1st more likely than May 2nd, because it could
also have been generated as April 31st.  (The Basis @code{Date.date}
normalizes the dates though, so you will never see April 31st.) *)
(*@findex weekday*)
val weekday : Date.weekday gen              
(*@findex month*)
val month : Date.month gen                  
(*@findex dateFromYear*)
val dateFromYear : int gen -> Date.date gen 
(*@findex time*)
val time : Time.time gen                    
(*>>*)
val dateFromUTC : Date.date gen  (* broken? *)
end
