signature FILESYS =
sig 
type ('a,'b) reader = 'b -> ('a * 'b) option
(*<<*)
(*@ The following functions generate file and directory names as 
test cases.  This is useful, for example, for regression tests of a 
compiler -- just keep a directory of source files to be compiled.
The directory stream should be read all the way to the end, or else
the directory handle will not be properly closed.  (The check function
does this automatically.)
 *)
type dirstream                              (*@tindex dirstream*)
val openDir : string -> dirstream           (*@findex openDir*)
val nextFile : (string, dirstream) reader   (*@findex nextFile*)
(*@ Here is an example of how to run tests on filenames in a 
directory:
@example
    check (FileSys.nextFile, pretty_printer)
          (test_name, test_predicate)
          (FileSys.openDir directory_path)
@end example
 *)

(*@ The following functions produce lines of text from a file as
test cases.  The produced strings include newlines, but see below 
for how to filter them.
 *)
type filestream                             (*@tindex filestream*)
val openFile : string -> filestream         (*@findex openFile*)
val nextLine : (string, filestream) reader  (*@findex nextLine*)

(*@ Here are some simple utilities for readers.  The types should be 
self-explanatory.  The @code{chop} function removes newlines from the 
ends of string readers (such as @code{nextLine}).
 *)
val map : ('a -> 'b) -> ('a,'c) reader -> ('b,'c) reader 
(*@findex map*)
val filter : ('a -> bool) -> ('a,'b) reader -> ('a,'b) reader 
(*@findex filter*)
val chop : (string,'a) reader -> (string,'a) reader 
(*@findex chop*)
(*>>*)
end
