signature TEXT =
sig structure Char            : Char
    structure String          : String
    structure Substring       : Substring
end

structure Text : TEXT =
struct
    structure Char = Char
    structure String = String
    structure Substring = Substring
end

signature INTEGER = Int
structure LargeInt = Int

signature WORD = 
sig eqtype word 
    val wordSize : int
    val fromString : string -> word option
    val fromInt : int -> word
    val andb : word * word -> word
    val >> : word * Word.word -> word
end

structure Word8' : WORD = 
struct
    open Word8
    type word = word8
end

structure TextStreamIO =
struct
  datatype elt = I of string * instream
               | D of TextIO.instream
               | E 
  withtype instream = elt ref

  fun getInstream i = ref(D i)

  fun inputLine p =
      case !p
       of E => NONE
        | I(s,i) => SOME(s,i)
        | D i => 
          case TextIO.inputLine i
           of "" => (TextIO.closeIn i; p := E; NONE)
            | ln => 
              let val p' = getInstream i
               in p := I(ln, p')
                ; SOME(ln, p')
              end
end
