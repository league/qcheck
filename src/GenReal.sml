(* gen/real.sml -- generate random real numbers from strings of digits
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 *
 * This library is free software; see the LICENSE file.
 *)

functor GenReal (include TEXT_GENERATOR
                 structure Real : REAL) : REAL_GENERATOR =
struct

type rand = rand
type 'a gen = 'a gen
type ('a,'b) co = ('a,'b) co
type real = Real.real

val digits = string (range(1, Real.precision),
                     charRange(#"0", #"9"))

fun frac r =
    let val (s,r) = digits r
     in (valOf(Real.fromString s), r)
    end

val {exp=minExp,...} = Real.toManExp Real.minPos
val {exp=maxExp,...} = Real.toManExp Real.posInf

val ratio = 99

fun mk r =
    let val (a,r) = digits r
        val (b,r) = digits r
        val (e,r) = range (minExp div 4, maxExp div 4) r
        val x = String.concat [a, ".", b, "E", Int.toString e]
     in (*print ("Trying: "^x^"\n");*)
        (valOf(Real.fromString x), r)
    end

val pos = chooseL' [(1, lift Real.posInf),
                    (1, lift Real.maxFinite),
                    (1, lift Real.minPos),
                    (1, lift Real.minNormalPos),
                    (ratio, mk)]

val neg = map Real.~ pos

val zero = Real.fromInt 0
val nonneg = chooseL' [(1, lift zero), (ratio, pos)]
val nonpos = chooseL' [(1, lift zero), (ratio, neg)]

val real = chooseL [nonneg, nonpos]

val finite = filter Real.isFinite real

end
