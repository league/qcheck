(* tests/reverse.sml -- list-reversal properties; from QuickCheck paper
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING.
 *)

structure TestReverse : sig end = struct
open QCheck

(* We test List.rev using integer lists (that ought to be enough,
   thanks to parametricity). *)

val rev : int list -> int list = List.rev

(* Here are the properties: Reversing a singleton list produces the
   same list (revUnit).  Reverse of concatenation is concatenation of
   reversals (revApp).  Reverse of reverse is identity (revRev). *)

val revUnit = pred ((fn x => rev [x] = [x]))
val revApp = trivial (fn(xs,ys) => null xs orelse null ys)
                     (pred ((fn(xs,ys) => rev (xs@ys) = rev ys @ rev xs)))

fun lc xs = 
    case length xs 
      of 0 => SOME "length 0"
       | 1 => SOME "length 1-2"
       | 2 => SOME "length 1-2"
       | 3 => SOME "length 3-5"
       | 4 => SOME "length 3-5"
       | 5 => SOME "length 3-5"
       | _ => NONE

val revRev = (classify' lc
                        (pred ((fn xs => rev (rev xs) = xs))))

(* To test revUnit, we need only generate integers, to form the
   singleton list *)

val _ = checkGen (Gen.Int.int, SOME Int.toString)
              ("rev unit", revUnit)

(* For the rests, we’ll need to generate integer lists.  The use of
   flip'(1,7) means that the probability of a nil will be 1 in 8. *)

val genL = Gen.list (Gen.flip'(1,7)) Gen.Int.int

val _ = checkGen (Gen.zip(genL,genL), NONE) ("rev app", revApp)

val _ = checkGen (genL, NONE) ("rev rev", revRev)

end
