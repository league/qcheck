(* settings.sml -- global user-customizable settings
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

signature SETTINGS =
sig 
    type 'a control
    val get : 'a control -> 'a
    val set : 'a control * 'a -> unit

    val gen_target : int option control
    val gen_max : int control
    val examples : int option control
    val outstream : TextIO.outstream control
    val column_width : int control
    val show_stats : bool control
    val style : string control
end

structure Settings =
struct 

open Controls
fun ctl (name, help, default) =
    genControl { name=name, help=help, default=default,
                 pri=[], obscurity=0 }

val gen_target = 
    ctl("gen_target", "Number of valid random cases to test", SOME 100)

val gen_max =
    ctl("gen_max", "Maximum number of random cases to consider", 400)

val examples = 
    ctl("errors", "Number of counter-examples to report", SOME 5)

val outstream = 
    ctl("outstream", "Output stream for test results", TextIO.stdErr)

val show_stats =
    ctl("show_stats", "Show distribution of test cases", true)

val column_width =
    ctl("column_width", "Width of test name column", 22)
end
