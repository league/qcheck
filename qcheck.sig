(* qcheck.sig -- main signatures for QCheck library
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

signature FILESYS =
sig type ('a,'b) reader = 'b -> ('a * 'b) option
    type dirstream
    val openDir : string -> dirstream
    val nextFile : (string, dirstream) reader

    type filestream
    val openFile : string -> filestream
    val nextLine : (string, filestream) reader

    val map : ('a -> 'b) -> ('a,'c) reader -> ('b,'c) reader
    val filter : ('a -> bool) -> ('a,'b) reader -> ('a,'b) reader
    val match : string -> (string,'a) reader -> (string,'a) reader
    val chop : (string,'a) reader -> (string,'a) reader
end

signature PROPERTY =
sig type 'a pred = 'a -> bool
    type 'a prop

    val pred : 'a pred -> 'a prop
    val pred2 : ('a * 'b) pred -> 'b -> 'a  prop
    val implies : 'a pred * 'a prop -> 'a prop
    val ==> : 'a pred * 'a pred -> 'a prop
    val trivial : 'a pred -> 'a prop -> 'a prop
    val classify : 'a pred -> string -> 'a prop -> 'a prop
    val classify' : ('a -> string option) -> 'a prop -> 'a prop

    type result = bool option
    type stats = { tags : StringBag.set,
                   count : int }

    val test : 'a prop -> 'a * stats -> result * stats
    val stats : stats
    val success : result pred
    val failure : result pred
end

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
