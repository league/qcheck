(* tests/compiler.sml -- demonstrates using external files for tests
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure TestCompiler = struct
open QCheck

local open Compiler.Control
in fun compiles file = 
       let val out = !Print.out
           fun return x = x before Print.out := out
        in Print.out := {flush=ignore, say=ignore}
         ; (use file; return true)
           handle _ => return false
       end
end

fun smallp file = OS.FileSys.fileSize file < 128

structure Regex = RegExpFn(structure P = AwkSyntax
                           structure E = BackTrackEngine)
val rc = Regex.compileString
fun match r = isSome o StringCvt.scanString (Regex.find r)

fun ck(name,re,p) = 
    check (Files.filter (match re) Files.nextFile, SOME(fn s => s))
          (name, trivial smallp (pred p))
          (Files.openDir "tests/data")
          handle exn as OS.SysErr _ =>
                 raise Fail "tests.cm should be run from source root"

val _ = ck("ML compiler accepts", rc "\\.acc$", compiles)
val _ = ck("ML compiler rejects", rc "\\.err$", not o compiles)

end
