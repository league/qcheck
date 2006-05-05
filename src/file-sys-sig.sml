signature FILESYS =
sig 
type ('a,'b) reader = 'b -> ('a * 'b) option
(*<<*)
type dirstream                              (*@tindex dirstream*)
val openDir : string -> dirstream           (*@findex openDir*)
val nextFile : (string, dirstream) reader   (*@findex nextFile*)

type filestream                             (*@tindex filestream*)
val openFile : string -> filestream         (*@findex openFile*)
val nextLine : (string, filestream) reader  (*@findex nextLine*)

val map : ('a -> 'b) -> ('a,'c) reader -> ('b,'c) reader 
(*@findex map*)
val filter : ('a -> bool) -> ('a,'b) reader -> ('a,'b) reader 
(*@findex filter*)
val chop : (string,'a) reader -> (string,'a) reader 
(*@findex chop*)
(*>>*)
end
