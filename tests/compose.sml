(* tests/compose.sml -- function composition is associative
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure TestCompose : sig end  = struct
open QCheck 

(* This is another example from the QuickCheck (Haskell) paper.  We
   can check that function composition is associative, by generating
   random functions (!).  It is simplest if they're monomorphic, so
   we'll choose int->int as our function types. *)

(* It's possible that these functions can generate 'overflow'
   exceptions on certain arguments; usually on maxInt/minInt.  This is
   okay, but let's make sure that they generate the SAME exception
   whether applied left- or right-associatively. *)

datatype result = Ok of int | Err of string
fun apply f x = Ok(f x) handle e => Err(exnMessage e)

fun assoc (f:int->int, g:int->int, h:int->int, x:int) =
    apply (f o (g o h)) x =
    apply ((f o g) o h) x

val g = Gen.arrow (Gen.Int.coint, Gen.Int.int)
val _ = checkGen (Gen.zip4(g,g,g,Gen.Int.int), NONE)
                 ("compose associative", pred assoc)
end
