signature SETTINGS =
sig 
(*<<*)
type 'a control                           (*@tindex control*)
val get : 'a control -> 'a                (*@findex get*)
val set : 'a control * 'a -> unit         (*@findex set*)
(*@ Many run-time parameters can be adjusted before running your unit
tests. *)

val gen_target : int option control       (*@findex gen_target*)
(*@ Number of valid random cases to test.  Default is 100. *)

val gen_max : int control                 (*@findex gen_max*)
(*@ Maximum number of random cases to consider; stop after this
many even if @code{gen_target} has not been reached.  Default is 400. *)

val examples : int option control         (*@findex examples*)
(*@ Maximum number of counter-examples to report.  Default is 5. *)

val outstream : TextIO.outstream control  (*@findex outstream*)
(*@ Output stream for test results. *)

val column_width : int control            (*@findex column_width*)
(*@ Width of test name column.  Its interpretation 
depends on the output style.  Default is 22.  *)

val show_stats : bool control             (*@findex show_stats*)
(*@ Show distribution of test cases.  Default is true. *)

val style :                               (*@findex style*)
    { name: string,
      ctor: string ->
            { status: string option * Property.result 
                      * Property.stats -> unit,
              finish: Property.stats -> bool } } control
(*@ This controls the style of the output.  See below. *)
(*>>*)
end
