signature PROPERTY =
sig type 'a pred = 'a -> bool
    type 'a prop

    val pred : 'a pred -> 'a prop
    val pred2 : ('a * 'b) pred -> 'b -> 'a  prop
    val implies : 'a pred * 'a prop -> 'a prop
    val ==> : 'a pred * 'a pred -> 'a prop
    val trivial : 'a pred -> 'a prop -> 'a prop
    val classify : 'a pred -> string -> 'a prop -> 'a prop
    val classify' : ('a -> string option) -> 'a prop -> 'a prop

    type result = bool option
    type stats = { tags : StringBag.bag,
                   count : int }

    val test : 'a prop -> 'a * stats -> result * stats
    val stats : stats
    val success : result pred
    val failure : result pred
end
