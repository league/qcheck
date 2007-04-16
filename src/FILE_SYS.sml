signature FILE_SYS =
sig 
type ('a,'b) reader = 'b -> ('a * 'b) option
(*<<*)
(*@findex FILE_SYS signature *)
(*@ The following functions generate file and directory names as 
test cases.  This is useful, for example, for regression tests of a 
compiler -- just keep a directory of source files to be compiled.
The directory stream should be read all the way to the end, or else
the directory handle will not be properly closed.  (The check function
does this automatically.)
 *)
(*@tindex dirstream*)
type dirstream                              
(*@findex openDir*)
val openDir : string -> dirstream           
(*@findex nextFile*)
val nextFile : (string, dirstream) reader   
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
(*@tindex filestream*)
type filestream                             
(*@findex openFile*)
val openFile : string -> filestream         
(*@findex nextLine*)
val nextLine : (string, filestream) reader  

(*@ Here are some simple utilities for readers.  The types should be 
self-explanatory.  The @code{chop} function removes newlines from the 
ends of string readers (such as @code{nextLine}).
 *)
(*@findex map*)
val map : ('a -> 'b) -> ('a,'c) reader -> ('b,'c) reader 
(*@findex filter*)
val filter : ('a -> bool) -> ('a,'b) reader -> ('a,'b) reader 
(*@findex chop*)
val chop : (string,'a) reader -> (string,'a) reader 
(*>>*)
end
