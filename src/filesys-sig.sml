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
    val chop : (string,'a) reader -> (string,'a) reader
end
