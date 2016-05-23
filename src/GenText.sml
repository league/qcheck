(* gen/text.sml -- generate random characters and strings
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 *
 * This library is free software; see the LICENSE file.
 *)

functor GenText (structure Gen : PREGEN_SIG
                 structure Text : TEXT) : PRETEXT_GENERATOR =
struct

open Gen Text
type char = Char.char
type string = String.string
type substring = Substring.substring


val char = map Char.chr (range (0, Char.maxOrd))
fun charRange (lo,hi) = map Char.chr (range (Char.ord lo, Char.ord hi))

fun charFrom s =
    choose (Vector.tabulate (String.size s,
                             fn i => lift (String.sub(s,i))))

fun charByType p = filter p char

val string = vector CharVector.tabulate

fun substring gen r =
    let val (s,r) = gen r
        val (i,r) = range (0, String.size s) r
        val (j,r) = range (0, String.size s - i) r
     in (Substring.substring(s,i,j), r)
    end

(* this should be similar to coword *)
fun cochar c =
    if Char.ord c = 0 then variant' (2,0)
    else cochar (Char.chr (Char.ord c div 2))
       o cobool (Char.ord c mod 2 <> 0)
       o variant' (2,1)

fun cosubstring s = colist cochar (Substring.explode s)

fun costring s = cosubstring (Substring.full s)

end
