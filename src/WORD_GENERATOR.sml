signature WORD_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@findex Word structures *)
(*@ The functions generating unsigned words are in structures such as
@code{Gen.Word}, @code{Gen.Word8}, @code{Gen,Word32}, etc., depending
on your implementation. *)
(*@tindex word*)
eqtype word                             
(*@findex word*)
val word : word gen                     
(*@findex coword*)
val coword : (word, 'b) co              
(*>>*)
end
