signature SETTINGS =
sig 
(*<<*)
type 'a control                           (*@tindex control*)
val get : 'a control -> 'a                (*@findex get*)
val set : 'a control * 'a -> unit         (*@findex set*)

val gen_target : int option control       (*@findex gen_target*)
val gen_max : int control                 (*@findex gen_max*)
val examples : int option control         (*@findex examples*)
val outstream : TextIO.outstream control  (*@findex outstream*)
val column_width : int control            (*@findex column_width*)
val show_stats : bool control             (*@findex show_stats*)
val style :                               (*@findex style*)
    { name: string,
      ctor: string ->
            { status: string option * Property.result 
                      * Property.stats -> unit,
              finish: Property.stats -> bool } } control
(*>>*)
end
