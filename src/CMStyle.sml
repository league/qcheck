(* styles/cm.sml -- meshes with CM output; highlighted in sml-mode
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 *
 * This library is free software; see the LICENSE file.
 *)

structure CMStyle =
struct

val name = "CM"
infix <<
fun os << f = f os
fun s str os = os before TextIO.output(os, str)
val i = s o Int.toString
fun pad wd = s o StringCvt.padLeft #"0" wd o Int.toString
fun return x _ = x

fun new tag =
let
    val os = TextIO.stdOut
    val _ = os <<s "[testing " <<s tag <<s "... "

    val tests = ref 0
    val errs = ref nil

    fun status (obj, result, stats) =
        (if isSome result then tests := !tests + 1
         else();
         if Property.failure result then errs := obj :: !errs
         else())

    fun finish stats = case (!tests, !errs)
     of (0, nil) =>
        os <<s "no valid cases generated]\n" << return true
      | (n, nil) =>
        (case Settings.get Settings.gen_target
           of NONE => os <<s "ok]\n" << return true
            | SOME goal =>
              (if n >= goal then os <<s "ok]\n" << return true
               else os <<s "ok on "
                       <<i n <<s "; "
                       <<i goal <<s " required]\n" << return true))
      | (_, es) =>
        let val wd = size(Int.toString(length es))
            fun each (NONE,i) = i+1
              | each (SOME e,i) =
                os <<s tag <<s ":"
                   <<pad wd i
                   <<s ".0 Error: " <<s e <<s "\n"
                   << return (i+1)
         in os <<s "FAILED]\n"
          ; foldr each 1 es
          ; false
        end

 in {status=status, finish=finish}
end

val style = {name="CM", ctor=new}

end
