(* bag.sml -- an unordered collection, where multiplicity is significant
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 *
 * This library is free software; see the LICENSE file.
 *)

(* We can represent a bag as a map from bag items to the number of
   times they occur in the bag.  Invariant: inDomain(map,item) ==>
   count(bag,item) > 0. *)

functor BagFromMap
        (M : sig type key
                 type 'a map
                 val empty : 'a map
                 val insert : 'a map * key * 'a -> 'a map
                 val find : 'a map * key -> 'a option
                 val foldli : (key * 'a * 'b -> 'b) -> 'b -> 'a map -> 'b
             end)
        :> BAG_SIG where type item = M.key
        =
struct
  type item = M.key
  type bag = int M.map
  val empty = M.empty
  fun singleton x = M.insert(M.empty, x, 1)
  fun count (m, x) = Option.getOpt(M.find(m, x), 0)
  fun add (m, x) = M.insert(m, x, count(m, x)+1)
  fun member(m, x) = isSome(M.find(m, x))
  val foldli = M.foldli
end

(*structure StringBag =
BagFromMap(RedBlackMapFn(open String type ord_key = string)) *)
