signature PROPERTY =
sig 
(*<<*)
type 'a pred = 'a -> bool                             (*@tindex pred*)
type 'a prop                                          (*@tindex prop*)
val pred : 'a pred -> 'a prop                         (*@findex pred*)
val pred2 : ('a * 'b) pred -> 'b -> 'a  prop          (*@findex pred2*)
val implies : 'a pred * 'a prop -> 'a prop            (*@findex implies*)
val ==> : 'a pred * 'a pred -> 'a prop                (*@findex ==>*)
val trivial : 'a pred -> 'a prop -> 'a prop           (*@findex trivial*)
val classify : 'a pred -> string -> 'a prop -> 'a prop(*@findex classify*)
val classify' : ('a -> string option) -> 'a prop ->   (*@findex classify'*)
                'a prop 

type result = bool option                             (*@tindex result*)
type stats = { tags : StringBag.bag,                  (*@tindex stats*)
               count : int }

val test : 'a prop -> 'a * stats -> result * stats    (*@findex test*)
val stats : stats                                     (*@findex stats*)
val success : result pred                             (*@findex success*)
val failure : result pred                             (*@findex failure*)
(*>>*)
end
