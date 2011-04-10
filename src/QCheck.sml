(* qcheck.sml -- main exported module; provides check function
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure QCheck : QCHECK_SIG =
struct

open QCheckVersion

structure Gen = RandGen
structure Files = Files
structure Settings = struct
  open Settings
  val style = ref PerlStyle.style
end

open Property 

type ('a,'b) reader = 'b -> ('a * 'b) option
type 'a rep = ('a -> string) option

fun ('a, 'b) cpsCheck (shrink:'a -> 'a list) (s0:Property.stats) (next : ('a, 's) reader, show : 'a rep) (prop : 'a prop) (status : string option * Property.result * Property.stats -> unit) (k : 'a list -> Property.stats -> 'b) : 's -> 'b =
  let
    val rep = case show 
     of NONE => (fn _ => NONE)
      | SOME f => SOME o f

    val badobjs = ref nil
    val status = fn (obj, result, stats) =>
      let val _ = if Property.failure result then badobjs := obj :: !badobjs
                  else ()
      in  status (rep obj, result, stats)
      end

    fun quit (_, NONE) = false
      | quit (n, SOME m) = n >= m

    fun lastTry obj stats =
      let val (result, stats) = Property.test prop (obj, stats)
      in  if Property.failure result then status (obj, result, stats)
          else let exception Can'tHappen in raise Can'tHappen end
      end

    fun tryShrink (obj: 'a) stats =
      let fun try [] = (print "\n"; lastTry obj stats)
            | try (small::smalls) =
                let val (result, _) = Property.test prop (small, stats)
                    val _ = print "."
                in  if Property.failure result then tryShrink small stats
                    else try smalls
                end
      in  print "Shrinking...";
          try (shrink obj)
      end

    fun iter(NONE, stats) = k (!badobjs) stats
      | iter(SOME(obj,stream), stats) = 
        if quit(#count stats, Settings.get Settings.gen_target) 
        then k (!badobjs) stats
        else let val (result, stats') = Property.test prop (obj, stats)
              in if Property.failure result then tryShrink obj stats
                 else status (obj, result, stats')
               ; iter(next stream, stats')
             end
 in fn stream => iter (next stream, s0)
end


fun check'' s0 shrink (next, show) (tag, prop) =
let 
    val {status, finish} = #ctor (Settings.get Settings.style) tag
in
    cpsCheck shrink s0 (next, show) prop status (fn _ => ignore o finish)
end

fun check' x = check'' x (fn _ => [])

fun check x = check' Property.stats x
fun checks x = check'' Property.stats x

fun checkGen (gen, show) (tag, prop) =
    check' {count=0, tags=StringBag.singleton "__GEN"}
           (Gen.limit gen, show) (tag, prop) Gen.stream

fun checkGenShrink shrink (gen, show) (tag, prop) =
    check'' {count=0, tags=StringBag.singleton "__GEN"} shrink
           (Gen.limit gen, show) (tag, prop) Gen.stream

fun checkOne show (tag, prop) obj =
    check (List.getItem, show)
          (tag, prop) [obj]

end
