(* filesys.sml -- test cases from files in a directory or lines in a file
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure FileSys : FILESYS =
struct

type ('a,'b) reader = 'b -> ('a * 'b) option
type dirstream = string * OS.FileSys.dirstream

fun openDir d = (d, OS.FileSys.openDir d)

fun nextFile(d,ds) = 
    case OS.FileSys.readDir ds
      of NONE => NONE before OS.FileSys.closeDir ds
       | SOME file => SOME(OS.Path.joinDirFile {dir=d, file=file}, (d,ds))

type filestream = TextIO.StreamIO.instream
val openFile = TextIO.getInstream o TextIO.openIn
val nextLine = TextIO.StreamIO.inputLine

fun map f get strm =
    case get strm of NONE => NONE
                   | SOME(x, strm) => SOME(f x, strm)

fun filter p get strm =
    case get strm of NONE => NONE
                   | SOME(x, strm) => if p x then SOME(x, strm)
                                      else filter p get strm

structure Regex = RegExpFn(structure P = AwkSyntax
                           structure E = BackTrackEngine)
fun match pat =
let val re = Regex.compileString pat
    val match' = isSome o StringCvt.scanString (Regex.find re)
 in filter match'
end

fun chop' s = 
    if size s = 0 then s
    else if String.sub(s, size s - 1) <> #"\n" then s
    else String.substring(s, 0, size s - 1)

fun chop x = map chop' x

end

