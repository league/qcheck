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
    val style : 
        { name: string,
          ctor: string ->
                { status: string option * Property.result 
                          * Property.stats -> unit,
                  finish: Property.stats -> bool } } control
end
