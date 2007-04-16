signature APPLICATIVE_RNG =
sig
(*<<*)
(*@findex GENERATOR_SIG signature*)
(*@ We begin with the raw random number generator.  The @code{new}
function generates a seed based on the current time.  The @code{range}
function produces random integers between those in the given pair,
inclusive.  The generator is applicative, in the sense that it returns
the new state of the random number generator.
*)
(*@tindex rand*)
type rand
(*@findex new*)
val new : unit -> rand
(*@findex range*)
val range : int * int -> rand -> int * rand
(*>>*)
val split : rand -> rand * rand
end
