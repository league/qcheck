(* gen/word.sml -- generate random multi-precision words
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

functor GenWord (include TEXT_GENERATOR
                 structure Word : WORD) : WORD_GENERATOR =
struct

type rand = rand
type 'a gen = 'a gen
type ('a,'b) co = ('a,'b) co
type word = Word.word

fun digits n = string (range(1,n), charFrom "0123456789ABCDEF")
val maxDigits = Real.ceil (real Word.wordSize / 4.0)

fun word r = 
    let val (s,r) = digits maxDigits r
     in (valOf(Word.fromString s), r)
        handle Overflow => word r
    end

val z = Word.fromInt 0
val one = Word.fromInt 1

fun coword w =
    if w = z then variant 0
    else let val b = Word.andb(w,one) <> z
             val w' = Word.>>(w,0w1)
          in if b then variant 1 o coword w'
             else variant 2 o coword w'
         end

end
