(* tests/from-to-str.sml -- toString o fromString == identity?
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING.
 *)

(* Lots of Basis types have fromString/toString functions.  The idea,
   whether specified explicitly or not, is that the string produced by
   toString ought to be parsable by fromString to generate the same
   object.  Conversely, the reverse direction should also (roughly) be
   identity -- but there are a few exceptions. *)

(* For example, (Int.fromString "000123") produces (SOME 123), but
   (Int.toString 123) sensibly produces just "123".  These two string
   representations are not equal, but we can say thay are, in some
   sense, equivalent.  So for each type, we'll specify a custom
   equivalence function. *)

(* Many Basis modules can be augmented to match this signature: *)

signature FROM_TO =
sig type t
    val toString : t -> string
    val fromString : string -> t option

    val eqT : t * t -> bool
    val eqStr : string * string -> bool

    val genT : t QCheck.Gen.gen
    val genStr : string QCheck.Gen.gen

    (* In addition to the from/to round-trip, we'll check that strings
       in the 'valid' list produce SOME object, while those in
       'invalid' produce NONE. *)
    val valid : string list
    val invalid : string list
    val name : string                   (* for identifying the type *)
end

(* Now, to make the Haskellites envious, we'll define the properties
   once in a functor, and instantiate it for each type we want to
   check. *)

functor TestFromToString (T : FROM_TO) : sig end = struct
open QCheck 

fun rcheck tag gen show prop =
    checkGen (gen, SOME show) (T.name^"/"^tag, prop)

(* Start with a value, and make the round-trip through a string
   representation *)

fun to v = T.eqT(v, valOf(T.fromString(T.toString v)))
val _ = rcheck "to-from" T.genT T.toString (pred to)

(* Start with a string, and round-trip through a value.  This one uses
   "implies", which means that the string must be parsable by
   fromString for the test to count.  If fromString returns NONE, then
   that case is not counted.  This demonstrates a conditional
   property. *)

val ok = isSome o T.fromString
fun from s = T.eqStr(s, T.toString(valOf(T.fromString s)))
val _ = rcheck "from-to" T.genStr (fn s => s) (implies(ok, pred from))

(* All strings in 'valid' list must produce SOME object *)
val _ = check (List.getItem, SOME (fn s => s))
              (T.name^"/valid", pred ok) T.valid
val _ = check (List.getItem, SOME (fn s => s))
              (T.name^"/invalid", pred (not o ok)) T.invalid

end


(* Let's try it on a few simple types: booleans, characters, and
   strings. *)

structure BFT = TestFromToString
   (open QCheck Bool 
    val name = "Bool"
    type t = bool
    val eqT = op=
    fun eqStr(s1,s2) = 
        String.map Char.toLower (String.substring(s1,0,4)) =
        String.map Char.toLower (String.substring(s2,0,4))
    val valid = ["false", "true", "False", "True", "falsey", "truer",
                 "FALSE", "TRUE", "FaLsE", "tRuE"]
    val invalid = ["", "f", "t", "y", "n", "notfalse"]
    val genT = Gen.flip
    val genStr = Gen.select (Vector.fromList valid))

structure CFT = TestFromToString
   (open QCheck Char 
    val name = "Char"
    type t = char
    val eqT = op=
    fun eqStr(s1,s2) = fromString s1 = fromString s2
    val valid = ["\\^C", "\\255", "\\  \n  \\a", "\\\\"]
    val invalid = ["", "\\", "\^C", "\\256", "\\  \n  \\"]
    val genT = QCheck.Gen.char
    val genStr = Gen.string (Gen.range(0,6), Gen.char))

structure S = TestFromToString
   (open QCheck String
    val name = "String"
    type t = string
    val eqT = op=
    val eqStr = op=
    val valid = ["", "\\\\", "abc\\123"]
    val invalid = ["\\", "\\^", "abc\\256"]
    val genT = Gen.string (Gen.range(0,64), Gen.char)
    val genStr = genT)

(* Dates are a fairly interesting test case, although it is rather
   unlikely that the string generate will ever produce a valid date
   string! *)

structure D = TestFromToString
   (open QCheck Date
    val name = "Date"
    type t = date
    fun eqT(d1,d2) = Date.compare(d1,d2) = EQUAL
    val genT = Gen.DateTime.dateFromYear (Gen.range (1980, 2010))
    (* avoid day of week when comparing *)
    fun eqStr(s1,s2) = 
        String.extract(s1,3,NONE) = String.extract(s2,3,NONE)
    fun genStr r = 
        let val(dow,r) = Gen.selectL ["Mon", "Thu", "Sat"] r
            val(mon,r) = Gen.selectL ["Jan", "Feb", "Dec"] r
            val(day,r) = Gen.range(1,28) r
            val day = StringCvt.padLeft #" " 2 (Int.toString day)
            val(h,r) = Gen.range(0,23) r
            val h = StringCvt.padLeft #"0" 2 (Int.toString h)
            val(y,r) = Gen.range(1972,2035) r
            val y = Int.toString y
         in (dow^" "^mon^" "^day^" "^h^":01:01 "^y, r)
        end
    val valid = ["Sat Jun 05 15:07:53 2004", "Sun Mar 25 14:00:00 1973"]
    val invalid = [""])


(* To test the various Integer types, we'll use the following functor
   as an adaptor. *)

functor IntFromTo(I : INTEGER) : FROM_TO =
struct
  open QCheck I
  type t = int
  val eqT = op=

  fun prec NONE = "Inf"
    | prec (SOME n) = Int.toString n

  val name = "Int" ^ prec I.precision

  fun len NONE = 64
    | len (SOME n) = Int.- (size(I.toString n), 1)

  structure GI = GenInt(open Gen structure Int = I)
  val genT = GI.int
  val genStr = Gen.string(Gen.range(0,len I.maxInt),
                             Gen.charFrom "0123456789")
    (* to compare strings, we need to drop leading "0"s *)
  fun zerop #"0" = true | zerop _ = false
  val dropZeros = Substring.dropl zerop o Substring.full
  fun eqStr (s1,s2) = 
      Substring.compare(dropZeros s1, dropZeros s2) = EQUAL

  val valid = ["000123", "0", "000", "012abc", "  34"]
  val invalid = ["", "aabc", "  a3"]
end



(***
structure R = TestFromToString
   (open Real
    type t = real
    fun eqT(a,b) = abs(a-b) < 1.0e~10
    val name = "Real"
    val genT = Gen.Real.real
    val genNum = Gen.string (Gen.range(1,6),
                                  Gen.charFrom "0123456789")
    val genString = Gen.map2 (fn(a,b) => a^"."^b) (genNum, genNum)
    (* to compare strings, we need to drop leading "0"s *)
    open Substring
    fun zerop #"0" = true | zerop _ = false
    fun norm s = 
        let val s = dropl zerop (all s)
         in if isSubstring "." s then dropr zerop s else s
        end
    fun eqString (s1,s2) = compare(norm s1, norm s2) = EQUAL
    )
 ***)


