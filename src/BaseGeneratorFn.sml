(* gen/base.sml -- tools for generating random data
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

functor BaseGeneratorFn(R : APPLICATIVE_RNG) : PREGEN_SIG =
struct

open R
type 'a gen = rand -> 'a * rand
type ('a,'b) reader = 'b -> ('a * 'b) option

fun lift obj r = (obj, r)

local open Vector
      fun explode ((freq, gen), acc) =
          List.tabulate (freq, fn _ => gen) @ acc
in fun choose v r =
       let val (i, r) = range(0, length v - 1) r
        in sub (v, i) r
       end
   fun choose' v = choose (fromList (foldr explode nil v))
   fun select v = choose (map lift v)
end

fun chooseL l = choose (Vector.fromList l)
fun chooseL' l = choose' (Vector.fromList l)
fun selectL l = select (Vector.fromList l)

fun zip (g1,g2) r = 
    let val (x1,r) = g1 r
        val (x2,r) = g2 r
     in ((x1,x2), r)
    end

fun zip3 (g1,g2,g3) r = 
    let val (x1,r) = g1 r
        val (x2,r) = g2 r
        val (x3,r) = g3 r
     in ((x1,x2,x3), r)
    end

fun zip4 (g1,g2,g3,g4) r = 
    let val (x1,r) = g1 r
        val (x2,r) = g2 r
        val (x3,r) = g3 r
        val (x4,r) = g4 r
     in ((x1,x2,x3,x4), r)
    end

fun map f g r = let val (x,r) = g r in (f x, r) end
fun map2 f = map f o zip
fun map3 f = map f o zip3
fun map4 f = map f o zip4

fun filter p gen r = 
    let fun loop(x,r) = if p x then (x,r) else loop (gen r)
     in loop(gen r)
    end

val flip = selectL [true, false]
fun flip' (p,q) = chooseL' [(p, lift true),
                            (q, lift false)]

fun list flip g r =
    case flip r
      of (true, r) => (nil, r)
       | (false, r) => 
         let val (x,r) = g r
             val (xs,r) = list flip g r
          in (x::xs, r)
         end

fun option flip g r =
    case flip r 
      of (true, r) => (NONE, r)
       | (false, r) => 
         let val (x, r) = g r
          in (SOME x, r)
         end

fun vector tabulate (int, elem) r =
    let val (n, r) = int r
        val p = ref r
        fun g _ = let val (x,r) = elem(!p)
                  in x before p := r
                  end
     in (tabulate(n, g), !p)
    end

type stream = rand ref * int
fun start r = (ref r, 0)
fun limit' max gen = 
    let fun next (p,i) =
            if i >= max then NONE
            else let val (x,r) = gen(!p)
                  in SOME(x, (p,i+1))
                     before p := r
                 end
     in next
    end

fun limit gen = limit' (Settings.get Settings.gen_max) gen

type ('a, 'b) co = 'a -> 'b gen -> 'b gen

fun splitrights (r,0) = r
  | splitrights (r,n) = splitrights (#2 (split r), n-1)

fun splitleft r = #1 (split r)

fun variant v g r =
    if v < 0 then raise Subscript
    else g (splitleft (splitrights (r,v)))

fun variant' (b,v) g r =
    if v < 0 orelse v >= b then raise Subscript
    else if v = b-1 then g (splitrights (r,v))
    else g (splitleft (splitrights (r,v)))

fun arrow (cogen, gen) r = 
    let val (r1, r2) = split r
        fun g x = 
            let val (y,_) = cogen x gen r1
             in y
            end
     in (g, r2)
    end

fun cobool false = variant' (2,0)
  | cobool true = variant' (2,1)

fun colist _ [] = variant' (2,0)
  | colist co (x::xs) = 
    colist co xs o co x o variant' (2,1)

fun coopt _ NONE = variant' (2,0)
  | coopt co (SOME x) = co x o variant' (2,1)

end 
