(* bag.sml -- an unordered collection, where multiplicity is significant
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

signature ORD_BAG =
sig
    include ORD_SET
    type bag = set
    val count : set * item -> int
    val appi : (item * int -> unit) -> set -> unit
    val foldli : (item * int * 'a -> 'a) -> 'a -> set -> 'a
    val foldri : (item * int * 'a -> 'a) -> 'a -> set -> 'a
end

(* We can represent a bag as a map from bag items to the number of
   times they occur in the bag.  Invariant: inDomain(map,item) ==>
   count(bag,item) > 0. *)

functor BagFromMap (M : ORD_MAP) :> ORD_BAG where Key = M.Key  =
struct

open M

type item = Key.ord_key
type set = int M.map
type bag = set

fun singleton x = M.singleton(x, 1)
fun count (m, x) = Option.getOpt(M.find(m, x), 0)
fun add (m, x) = M.insert(m, x, count(m, x)+1)
fun add' (x, m) = add(m, x)
fun addList (m, L) = List.foldr add' m L
fun delete (m, x) = 
    case M.find(m, x) of NONE => m
                       | SOME n => M.insert(m, x, n-1)
val member = M.inDomain
val compare = M.collate Int.compare

fun relop p (m1, m2) =
    let exception Not
        fun check(x,n) =
            if p(n, count(m2,x))then ()
            else raise Not
     in (M.appi check m1; true)
        handle Not => false
    end

val equal = relop op=
val isSubset = relop op<
val numItems = M.foldr op+ 0

fun dup (x,0,L) = L
  | dup (x,n,L) = x :: dup(x,n-1,L)

val listItems = M.foldri dup nil 

val union = M.unionWith op+
val intersection = M.intersectWith Int.min

fun difference (m1, m2) =
    let fun sub (k,i,m3) =
            case M.find(m2,k)
             of NONE => M.insert(m3,k,i)
              | SOME j => if i <= j then m3
                          else M.insert(m3,k,i-j)
     in M.foldri sub M.empty m1
    end

(* Assumption: semantically, it would be strange for map's function
   argument to (using side effects) produce a different mapping each
   time it is called.  Therefore, we'll just apply once to each unique
   element. *)

fun map f =
    M.foldri (fn (k,i,m) => M.insert(m, f k, i)) M.empty

(* Semantically, app is different.  We'll apply as many times as the
   element exists in the bag. *)

fun app f = 
    let fun repeat(k,0) = ()
          | repeat(k,i) = (f k; repeat(k, i-1))
     in M.appi repeat
    end

fun loop f (k,0,acc) = acc
  | loop f (k,i,acc) = loop f (k, i-1, f(k, acc))

fun foldl f = M.foldli (loop f)
fun foldr f = M.foldri (loop f)

fun partition p =
    M.foldri (fn (k,n,(mt,mf)) => 
                 if p k then (M.insert(mt,k,n), mf)
                 else (mt, M.insert(mf,k,n)))
             (M.empty, M.empty)

fun filter p = M.filteri (p o #1)

fun find p m = 
    let exception Found of item
        fun check k = if p k then raise Found k else ()
     in (app check m; NONE)
        handle Found x => SOME x
    end

fun exists p = Option.isSome o (find p)

end

structure StringBag = 
BagFromMap(RedBlackMapFn(open String type ord_key = string))
