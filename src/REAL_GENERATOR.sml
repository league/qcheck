signature REAL_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@findex Real structure *)
(*@ These are in @code{Gen.Real} structure.  Currently, real numbers are
generated from strings of (decimal) digits, rather than from bits.
So some valid reals will never be generated. This may not be sufficient
for testing numerical code. *)
(*@tindex real*)
type real                               
(*@findex real*)
val real : real gen                     
(*@findex frac*)
val frac : real gen                     
(*@findex pos*)
val pos : real gen                      
(*@findex neg*)
val neg : real gen                      
(*@findex nonpos*)
val nonpos : real gen                   
(*@findex nonneg*)
val nonneg : real gen                   
(*@findex finite*)
val finite : real gen                   
(*>>*)
end
