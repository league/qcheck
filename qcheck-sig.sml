(* qcheck.sig -- main signatures for QCheck library
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

signature QCHECK =
sig
    val version : int * int
    structure Gen : GENERATOR
    structure FileSys : FILESYS
    structure Settings : SETTINGS
    include PROPERTY
    
    type ('a,'b) stream = 'b -> ('a * 'b) option
    type 'a rep = ('a -> string) option

    val check : ('a,'b) stream * 'a rep ->
                string * 'a prop -> 'b -> unit

    val checkGen : 'a Gen.gen * 'a rep ->
                   string * 'a prop -> unit

    val checkOne : 'a rep -> string * 'a prop -> 'a -> unit
end
