(* prop.sml -- conditional properties that can track argument distribution
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure Property :> PROPERTY =
struct

type result = bool option
type stats = { tags : StringBag.bag,
               count : int }
type 'a pred = 'a -> bool
type 'a prop = 'a * stats -> result * stats

fun success (SOME true) = true
  | success _ = false

fun failure (SOME false) = true
  | failure _ = false

fun apply f x = SOME(f x) handle _ => SOME false
fun pred f (x,s) = (apply f x, s)
fun pred2 f z = pred (fn x => f(x,z))

fun implies(cond, p) (x,s) =
    if cond x then p (x,s)
    else (NONE, s)

fun ==> (p1,p2) = implies(p1, pred p2)

fun wrap trans p (x,s) = 
    let val (result,s) = p(x,s)
     in (result, trans (x, result, s))
    end

fun classify' f =
    wrap (fn(x, result, {tags,count})=>
            { tags = if isSome result then
                          case f x of NONE => tags
                                    | SOME tag => StringBag.add(tags, tag)
                      else tags,
              count = count })

fun classify p tag = 
    classify' (fn x => if p x then SOME tag else NONE)

fun trivial cond = classify cond "trivial"

fun test p =
    wrap (fn(_, result, {tags,count})=>
            { tags = tags,
              count = if isSome result then count+1 else count })
         p

val stats = { tags = StringBag.empty,
              count = 0 }

end
