signature PRETEXT_GENERATOR =
sig
    include PREGEN_SIG
(*<<*)
(*@
@section Basis types
In addition to the general combinators, practically all of the
SML Basis types have associated generators in sub-structures.  The
following generators can be instantiated for whatever character and
string types your implementation provides, such as
@code{Gen.WideText.charByType}.  For the default character and string
types, however, these are found in the top-level of the @code{Gen}
structure. *)
(*@tindex char*)        
type char                                       
(*@tindex string*)      
type string                                     
(*@tindex substring*)   
type substring                                  
(*@findex char*)        
val char : char gen                             
(*@findex charRange*)   
val charRange : char * char -> char gen         
(*@findex charFrom*)    
val charFrom : string -> char gen               
(*@findex charByType*)  
val charByType : (char -> bool) -> char gen     
(*@findex string*)      
val string : (int gen * char gen) -> string gen 
(*@findex substring*)   
val substring : string gen -> substring gen     
(*@findex cochar*)      
val cochar : (char, 'b) co                      
(*@findex costring*)    
val costring : (string, 'b) co                  
(*@findex cosubstring*) 
val cosubstring : (substring, 'b) co            
(*>>*)
end
