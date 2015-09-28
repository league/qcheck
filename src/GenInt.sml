(* gen/int.sml -- generate random multi-precision integers
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)


functor GenInt (include TEXT_GENERATOR
                structure Int : INTEGER) : 
        INT_GENERATOR =
struct

type rand = rand
type 'a gen = 'a gen
type ('a,'b) co = ('a,'b) co
type int = Int.int

val digit = charRange (#"0", #"9")
val nonzero = string (lift 1, charRange (#"1", #"9"))
fun digits' n = string (range(0,n-1), digit)
fun digits n = map2 op^ (nonzero, digits' n)

val maxDigits = case Int.maxInt 
                 of NONE => 64
                  | SOME n => size (Int.toString n)

val ratio = 49

fun pos_or_neg f extremum =
let fun mk r =
        let val (s,r) = digits maxDigits r
         in (f(valOf(Int.fromString s)), r)
            handle Overflow => mk r
        end
 in case extremum
     of NONE => mk
      | SOME n => chooseL' [(1, lift n), (ratio, mk)]
end

val pos = pos_or_neg (fn x => x) Int.maxInt
val neg = pos_or_neg Int.~ Int.minInt
val z = Int.fromInt 0
val two = Int.fromInt 2 
    handle Overflow => (print "Error: need at least 3-bit ints\n";
                        raise Overflow)
val zero = lift z

val nonneg = chooseL' [(1, zero), (ratio, pos)]
val nonpos = chooseL' [(1, zero), (ratio, neg)]
val int = chooseL [nonneg, nonpos]

(* this should be similar to coword *)
fun coabs n =
    if n = z then variant' (2,0)
    else coabs (Int.quot(n, two))
       o cobool (Int.mod(n, two) <> z)
       o variant' (2,1)

fun coint n = 
    if n = z then variant' (2,0)
    else coabs (Int.quot(n, two))
       o cobool (Int.mod(n, two) <> z)
       o cobool (Int.< (n, z))
       o variant' (2,1)

end
