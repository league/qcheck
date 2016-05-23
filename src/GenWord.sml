(* gen/word.sml -- generate random multi-precision words
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 *
 * This library is free software; see the LICENSE file.
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

(* this should be equivalent to @code{colist cobool bits} *)
fun coword w =
    if w = z then variant' (2,0)
    else coword (Word.>>(w, 0w1))
       o cobool (Word.andb(w, one) <> z)
       o variant' (2,1)

end
