(* settings.sml -- global user-customizable settings
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure Settings =
struct 

type 'a control = 'a ref
val get = op!
val set = op:=

val gen_target = ref(SOME 100) (* Number of valid random cases to test *)
val gen_max = ref 400 (* Maximum number of random cases to consider *)
val examples = ref(SOME 5)  (* Number of counter-examples to report *)
val outstream = ref TextIO.stdErr (* Output stream for test results *)
val show_stats = ref true        (* Show distribution of test cases *)
val column_width = ref 22              (* Width of test name column *)

end
