(* gen/text.sml -- generate random characters and strings
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

functor GenText (structure Gen : GENERATOR'
                 structure Text : TEXT) : TEXT_GENERATOR' =
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

fun cochar c =
    if Char.ord c = 0 then variant 0
    else variant 1 o cochar (Char.chr (Char.ord c div 2))

fun cosubstring s =
    Substring.foldr (fn(c,v) => cochar c o v) (variant 0) s

fun costring s = cosubstring (Substring.full s)

end
