signature GEN_TYPES =
sig
type rand
(*<<*)
(*@ The generator for a type takes a random number stream
and produces a value of that type, along with the new state
of the stream. *)
(*@tindex gen*)
type 'a gen = rand -> 'a * rand
(*@tindex co*)
type ('a, 'b) co = 'a -> 'b gen -> 'b gen
(*>>*)
end
