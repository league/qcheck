(* styles/style.sml -- basic definitions for pluggable output styles 
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure StyleRep =
struct

type obj = 
     { status : string option * Property.result * Property.stats -> unit,
       finish : Property.stats -> bool }

type style = 
     { name : string,
       ctor : string -> obj }

local
    val map : style AtomMap.map ref = ref AtomMap.empty
    val lc = Atom.atom o CharVector.map Char.toLower

    fun fromString s = AtomMap.find(!map, lc s)
    fun toString {name, ctor} = name

in fun register sty = 
       map := AtomMap.insert(!map, lc (#name sty), sty)

   val cvt : style Controls.value_cvt =
       { tyName = "style",
         fromString = fromString,
         toString = toString }

end

end
