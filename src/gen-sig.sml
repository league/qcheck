(* gen/gen.sig -- signatures for random data generation
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

signature APPLICATIVE_RNG = 
sig type rand
    val new : unit -> rand
    val range : int * int -> rand -> int * rand
    val split : rand -> rand * rand
end

signature GEN_TYPES =
sig type rand
    type 'a gen = rand -> 'a * rand
    type ('a, 'b) co = 'a -> 'b gen -> 'b gen
end

signature GENERATOR' = 
sig include GEN_TYPES
    val new : unit -> rand
    val range : int * int -> rand -> int * rand
    val lift : 'a -> 'a gen
    val select : 'a vector -> 'a gen
    val choose : 'a gen vector -> 'a gen
    val choose' : (int * 'a gen) vector -> 'a gen
    val selectL : 'a list -> 'a gen
    val chooseL : 'a gen list -> 'a gen
    val chooseL' : (int * 'a gen) list -> 'a gen
    val filter : ('a -> bool) -> 'a gen -> 'a gen
    val zip : ('a gen * 'b gen) -> ('a * 'b) gen
    val zip3 : ('a gen * 'b gen * 'c gen) -> ('a * 'b * 'c) gen
    val zip4 : ('a gen * 'b gen * 'c gen * 'd gen) -> ('a * 'b * 'c * 'd) gen
    val map : ('a -> 'b) -> 'a gen -> 'b gen
    val map2 : ('a * 'b -> 'c) -> ('a gen * 'b gen) -> 'c gen
    val map3 : ('a * 'b * 'c -> 'd) -> ('a gen * 'b gen * 'c gen) -> 'd gen
    val map4 : ('a * 'b * 'c * 'd -> 'e) -> 
               ('a gen * 'b gen * 'c gen * 'd gen) -> 'e gen

    val flip : bool gen
    val flip' : int * int -> bool gen
    val list : bool gen -> 'a gen -> 'a list gen
    val option : bool gen -> 'a gen -> 'a option gen
    val vector : (int * (int -> 'a) -> 'b) ->
                 int gen * 'a gen -> 'b gen

    val variant : (int,'b) co
    val arrow : ('a, 'b) co * 'b gen -> ('a -> 'b) gen
    val cobool : (bool, 'b) co
    val colist : ('a, 'b) co -> ('a list, 'b) co
    val coopt : ('a, 'b) co -> ('a option, 'b) co

    type stream
    val start : rand -> stream
    val limit' : int -> 'a gen -> ('a,stream) StringCvt.reader
    val limit : 'a gen -> ('a,stream) StringCvt.reader
end

signature TEXT_GENERATOR' =
sig
    include GENERATOR'
    type char
    type string
    type substring
    val char : char gen
    val charRange : char * char -> char gen
    val charFrom : string -> char gen
    val charByType : (char -> bool) -> char gen
    val string : (int gen * char gen) -> string gen
    val substring : string gen -> substring gen
    val cochar : (char, 'b) co
    val costring : (string, 'b) co
    val cosubstring : (substring, 'b) co
end

signature TEXT_GENERATOR = TEXT_GENERATOR'
  where type char = char
    and type string = string
    and type substring = substring

signature INT_GENERATOR =
sig include GEN_TYPES
    eqtype int
    val int : int gen
    val pos : int gen
    val neg : int gen
    val nonpos : int gen
    val nonneg : int gen
    val coint : (int, 'b) co
end

signature WORD_GENERATOR =
sig include GEN_TYPES
    eqtype word
    val word : word gen
    val coword : (word, 'b) co
end

signature REAL_GENERATOR =
sig include GEN_TYPES
    type real
    val real : real gen
    val frac : real gen
    val pos : real gen
    val neg : real gen
    val nonpos : real gen
    val nonneg : real gen
    val finite : real gen
end

signature DATE_TIME_GENERATOR =
sig include GEN_TYPES
    val weekday : Date.weekday gen
    val month : Date.month gen
    val dateFromYear : int gen -> Date.date gen
    val dateFromUTC : Date.date gen  (* broken? *)
    val time : Time.time gen
end
