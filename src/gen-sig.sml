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
val lift : 'a -> 'a gen                           (*@findex lift*)
val select : 'a vector -> 'a gen                  (*@findex select*)
val choose : 'a gen vector -> 'a gen              (*@findex choose*)
val choose' : (int * 'a gen) vector -> 'a gen     (*@findex choose'*)
val selectL : 'a list -> 'a gen                   (*@findex selectL*)
val chooseL : 'a gen list -> 'a gen               (*@findex chooseL*)
val chooseL' : (int * 'a gen) list -> 'a gen      (*@findex chooseL'*)
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

val flip : bool gen                               (*@findex flip*)
val flip' : int * int -> bool gen                 (*@findex flip'*)
val list : bool gen -> 'a gen -> 'a list gen      (*@findex list*)
val option : bool gen -> 'a gen -> 'a option gen  (*@findex option*)
val vector : (int * (int -> 'a) -> 'b) ->         (*@findex vector*)
             int gen * 'a gen -> 'b gen

val variant : (int,'b) co                         (*@findex variant*)
val arrow : ('a, 'b) co * 'b gen -> ('a -> 'b) gen(*@findex arrow*)
val cobool : (bool, 'b) co                        (*@findex cobool*)
val colist : ('a, 'b) co -> ('a list, 'b) co      (*@findex colist*)
val coopt : ('a, 'b) co -> ('a option, 'b) co     (*@findex coopt*)

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
eqtype word                             (*@tindex word*)
val word : word gen                     (*@findex word*)
val coword : (word, 'b) co              (*@findex coword*)
(*>>*)
end

signature REAL_GENERATOR =
sig include GEN_TYPES
(*<<*)
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
val weekday : Date.weekday gen              (*@findex weekday*)
val month : Date.month gen                  (*@findex month*)
val dateFromYear : int gen -> Date.date gen (*@findex dateFromYear*)
val time : Time.time gen                    (*@findex time*)
(*>>*)
val dateFromUTC : Date.date gen  (* broken? *)
end
