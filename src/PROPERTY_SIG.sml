signature PROPERTY_SIG =
sig 
(*<<*)
(*@ A predicate is just a boolean function over some type.  A property
carries some additional data about preconditions and statistics.
*)
type 'a pred = 'a -> bool                             (*@tindex pred*)
type 'a prop                                          (*@tindex prop*)
val pred : 'a pred -> 'a prop                         (*@findex pred*)
val pred2 : ('a * 'b) pred -> 'b -> 'a  prop          (*@findex pred2*)

(*@ This function and operator are the same: they construct conditional
properties.  Test cases that fail the precondition are not counted. *)
val implies : 'a pred * 'a prop -> 'a prop            (*@findex implies*)
val ==> : 'a pred * 'a pred -> 'a prop                (*@findex ==>*)

(*@ 
@section Statistical distribution
One problem with random test-case generation is that we don't know 
for sure what we're getting.  QCheck provides a way to observe the 
distribution of test cases by tagging them based on user-definable
criteria.  For example, suppose we want to test the @code{ListMergeSort}
module in the SML/NJ library, by generating random integer lists.

If we generate and pass 100 cases, what does that mean?  Sorting a list
with fewer than 2 elements is pretty easy, so how many of our 100 cases 
are that trivial?  Also, how many of the lists are already ordered?  The
following functions are designed to help you answer such questions.
 *)
val trivial : 'a pred -> 'a prop -> 'a prop           (*@findex trivial*)
val classify : 'a pred -> string -> 'a prop -> 'a prop(*@findex classify*)
val classify' : ('a -> string option) -> 'a prop ->   (*@findex classify'*)
                'a prop 
(*@ Here are some examples of how they work.
@example
fun fewer_than n L = length L < n

val sort_ok = ListMergeSort.sorted op> o
              ListMergeSort.sort op>

val sort_test = trivial (fewer_than 2)
               (classify (ListMergeSort.sorted op>) "pre-sorted"
               (pred sort_ok))

checkGen (Gen.list (Gen.flip'(1,9)) Gen.Int.int, NONE)
         ("ListMergeSort", sort_test)
@end example
Now the test result, if passing, will be accompanied with some
statistics on the distribution of the specified properties.
@example
@print{} ListMergeSort..........ok      (100 passed)         33% pre-sorted
@print{}                                                     28% trivial
@end example
The functions @code{classify} and @code{trivial} are specializations of
the more general @code{classify'} (prime), with which we can provide a 
function that returns the tag.  To see the complete distribution of list 
lengths, try this:
@example
fun sizeTag n = 
    "length "^ StringCvt.padLeft #" " 3 (Int.toString n)

val sort_test = classify' (SOME o sizeTag o length) (pred sort_ok)
checkGen (Gen.list (Gen.flip'(1,9)) Gen.Int.int, NONE)
         ("ListMergeSort", sort_test)

@print{} ListMergeSort..........ok      (100 passed)         13% length   0
@print{}                                                      7% length   1
@print{}                                                      6% length   2
@print{}                                                     13% length   3
@print{}                                                      8% length   4
@print{}                                                      6% length   5
@print{}                                                      3% length   6
@print{}                                                      2% length   7
@print{}                                                      5% length   8
@print{}                                                      5% length   9
@print{}                                                      2% length  10
@print{}                                                      5% length  11
@print{}                                                      3% length  12
@end example
The list goes on: the maximum length list generated in this run was
43.
*)

(*@
@section Results
*)
type result = bool option                             (*@tindex result*)
type stats = { tags : StringBag.bag,                  (*@tindex stats*)
               count : int }

val test : 'a prop -> 'a * stats -> result * stats    (*@findex test*)
val stats : stats                                     (*@findex stats*)
val success : result pred                             (*@findex success*)
val failure : result pred                             (*@findex failure*)
(*>>*)
end
