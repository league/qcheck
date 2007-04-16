signature INT_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@findex Int structures *)
(*@ The functions in @code{Gen.Int} (and @code{Gen.Int32}, @code{Gen.IntInf},
etc.) generate integers in various ranges.  They can easily be instantiated
for whatever integer types your implementation provides.  They are biased
so that zero, @code{maxInt}, and @code{minInt} (if they exist) are
generated much more often than other integers. *)
(*@tindex int*)
eqtype int                              
(*@findex int*)
val int : int gen                       
(*@findex pos*)
val pos : int gen                       
(*@findex neg*)
val neg : int gen                       
(*@findex nonpos*)
val nonpos : int gen                    
(*@findex nonneg*)
val nonneg : int gen                    
(*@findex coint*)
val coint : (int, 'b) co                
(*>>*)
end
