(* tests/regex.sml -- demonstrates generation of recursive datatype
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING.
 *)

functor TestRegexEng
            (structure E : REGEXP_ENGINE
             val name : string) =
struct

open QCheck RegExpSyntax

(* first, generate a random regex abstract syntax tree *)
val gc = Gen.charRange(#"a", #"z")
fun gl g = Gen.vector List.tabulate (Gen.range(1,3), g)
val gcs = Gen.map (fn L => CharSet.addList (CharSet.empty, L))
                    (gl gc)

(* generate a sub-range between m,n *)
fun gsubr (m,n) r =
    let val(i,r) = Gen.range(m,n-1) r
        val(j,r) = Gen.option (Gen.flip'(1,3)) (Gen.range(i+1,n)) r
     in ((i,j),r)
    end

val gleaf = 
    Gen.choose #[ Gen.map MatchSet gcs
                 ,Gen.map NonmatchSet gcs
                 ,Gen.map Char gc
            (*   ,Gen.lift Begin  *)
            (*   ,Gen.lift End    *)
                 ]

fun genRegexAst 0 = gleaf
  | genRegexAst d = 
    let val re = genRegexAst (d div 2)
        val gnode = 
            Gen.choose #[ Gen.map Group re
                         ,Gen.map Alt (gl re)
                         ,Gen.map Concat (gl re)
                         ,(Gen.map2 (fn(s,(i,j))=> Interval(s,i,j)) 
                                    (re, gsubr(0,8)))
                         ,Gen.map Option re
                         ,Gen.map Star re
                         ,Gen.map Plus re 
                         ]
     in Gen.choose #[gleaf, gnode]
    end

fun genRegexTop r =
let val (ast,r) = genRegexAst 16 r
    val (pre,r) = Gen.flip'(1,4) r
    val (post,r) = Gen.flip'(1,4) r
    val ast = if pre then Concat [Begin,ast] else ast
    val ast = if post then Concat [ast,End] else ast
 in (ast,r)
end

fun size re = case re
 of (Begin | End | Char _ | MatchSet _ | NonmatchSet _) => 1
  | (Group r | Star r | Plus r | Option r | Interval(r,_,_)) => size r + 1
  | (Alt rs | Concat rs) => foldr op+ 1 (map size rs)

fun sizeClass n = 
    if n <= 4 then        "size  1-4 nodes"
    else if n <= 8 then   "size  5-8"
    else if n <= 16 then  "size  9-16"
    else if n <= 32 then  "size 17-32"
    else if n <= 64 then  "size 33-64"
    else if n <= 128 then "size 65-128"
    else                  "size >128"

(* if something goes wrong, we'll need to output the regex *)
infix <<
fun os << f = f os
fun put str L = str::L
fun ends L = String.concat(rev L)

fun set S os =
    CharSet.foldl (fn(c,os) => os << put(str c)) os S

fun show re os = case re
 of Begin => os << put "^"
  | End => os << put "$"
  | (Char c) => os << put(str c)
  | (Group r) => os << put "(" << show r << put ")"
  | (Star r) => os << show r << put "*"
  | (Plus r) => os << show r << put "+"
  | (Option r) => os << show r << put "?"
  | (Interval(r,x,NONE)) => 
    os << show r << put "{" 
       << put(Int.toString x) << put "-}"
  | (Interval(r,x,SOME y)) => 
    os << show r << put "{"
       << put(Int.toString x) << put "-"
       << put(Int.toString y) << put "}"
  | (MatchSet S) => 
    os << put "[" << set S << put "]"
  | (NonmatchSet S) => 
    os << put "[^" << set S << put "]"
  | Alt nil => os << put "()"
  | Alt(r::rs) => 
    foldl (fn(r,os) => os << put "|" << show r)
          (os << show r) rs
  | Concat rs => 
    foldl (fn(r,os) => show r os) os rs

and showL rs os =
    foldl (fn(re,os) => os << show re) os rs

fun show' re = ends (show re nil)


(* here's the test: try to compile it *)
val prop_comp = classify'(SOME o sizeClass o size)
                         (pred (fn syn => (E.compile syn; true)))


val()=
   checkGen (genRegexTop, SOME show')
            (name^"/compile", prop_comp)

end

structure Dfa = TestRegexEng(structure E=DfaEngine val name = "DFA")
structure Bt = TestRegexEng(structure E=BackTrackEngine val name = "Backtrack")
