(* qcheck.sml -- main exported module; provides check function
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure QCheck : QCHECK =
struct

open QCheckVersion

structure Gen = RandGen
structure FileSys = FileSys
structure Settings = struct
  open Settings
  val style = ref PerlStyle.style
end

open Property 

type ('a,'b) stream = 'b -> ('a * 'b) option
type 'a rep = ('a -> string) option

fun check' s0 (next, show) (tag, prop) =
let 
    val {status, finish} = #ctor (Settings.get Settings.style) tag

    val rep = case show 
     of NONE => (fn _ => NONE)
      | SOME f => SOME o f

    fun quit (_, NONE) = false
      | quit (n, SOME m) = n >= m

    val react = ignore

    fun iter(NONE, stats) = react(finish stats)
      | iter(SOME(obj,stream), stats) = 
        if quit(#count stats, Settings.get Settings.gen_target) 
        then react(finish stats)
        else let val (result, stats) = Property.test prop (obj, stats)
              in status (rep obj, result, stats)
               ; iter(next stream, stats)
             end
 in fn stream => iter (next stream, s0)
end

fun check x = check' Property.stats x

fun checkGen (gen, show) (tag, prop) =
    check' {count=0, tags=StringBag.singleton "__GEN"}
           (Gen.limit gen, show) (tag, prop) Gen.stream

fun checkOne show (tag, prop) obj =
    check (List.getItem, show)
          (tag, prop) [obj]

end
