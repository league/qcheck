(* filesys.sml -- test cases from files in a directory or lines in a file
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 *
 * This library is free software; see the LICENSE file.
 *)

structure Files : FILES_SIG =
struct

type ('a,'b) reader = 'b -> ('a * 'b) option
type dirstream = string * OS.FileSys.dirstream

fun openDir d = (d, OS.FileSys.openDir d)

fun nextFile(d,ds) =
    case OS.FileSys.readDir ds
      of NONE => NONE before OS.FileSys.closeDir ds
       | SOME file => SOME(OS.Path.joinDirFile {dir=d, file=file}, (d,ds))

type filestream = TextStreamIO.instream
val openFile = TextStreamIO.getInstream o TextIO.openIn
val nextLine = TextStreamIO.inputLine

fun map f get strm =
    case get strm of NONE => NONE
                   | SOME(x, strm) => SOME(f x, strm)

fun filter p get strm =
    case get strm of NONE => NONE
                   | SOME(x, strm) => if p x then SOME(x, strm)
                                      else filter p get strm

fun chop' s =
    if size s = 0 then s
    else if String.sub(s, size s - 1) <> #"\n" then s
    else String.substring(s, 0, size s - 1)

fun chop x = map chop' x

end
