QCheck
======

[![Build Status](https://travis-ci.org/league/qcheck.svg?branch=master)](https://travis-ci.org/league/qcheck)

QCheck is a library for automatic unit testing of Standard ML modules.
You provide specifications (in the form of ML code) of the properties
that your module's functions should satisfy, and ask QCheck to exercise
the module with randomly-chosen test cases.  It will show how many cases
passed the test, and print counter-examples in case of failure.
Actually, random testing is just one possibility; QCheck can pull test
cases from any kind of stream (disk file, data structure, etc.)

1.1 Simple properties of integers
=================================

The best way to demonstrate the capabilities of QCheck is with a simple
example.  Let's begin by writing a few tiny functions on integers:
successor, even, and odd:

     fun succ x = x+1
     fun even x = x mod 2 = 0
     fun odd x = x mod 2 = 1
      ⊣ val succ = fn : int → int
      ⊣ val even = fn : int → bool
      ⊣ val odd = fn : int → bool

Now we need to think of a property that we expect to hold for this
implementation.  Here is a trivial one: every integer is _either_ even
or odd.  That is, for any `x` exactly _one_ of the functions `even` or
`odd` returns true; the other returns false.  One way to specify this in
ML is to use `<>` (not equal), which amounts to an exclusive OR when
applied to boolean values.

     fun even_xor_odd x = even x <> odd x
      ⊣ val even_xor_odd = fn : int → bool

We now call upon QCheck to test this property on a bunch of randomly
chosen integers.  QCheck checkers are polymorphic.  To test integers,
we'll have to specify two things: a _generator_ that produces integers,
and a _printer_ that can convert integers to strings (in case there are
counter-examples to be printed).

     open QCheck infix ==>
     val int = (Gen.Int.int, SOME Int.toString)
      ⊣ val int = (fn,SOME fn) : int Gen.gen * (int → string) option

Finally, we call `checkGen` with the `int` spec, a string to identify
the test, and the property we are testing.

     checkGen int ("even<>odd", pred even_xor_odd);
      ⊣ even<>odd..............ok      (100 passed)
      ⊣ val it = () : unit

The output indicates that QCheck tested the property on 100 random
integers, and all of them succeeded.  (The number of cases required to
complete the test is configurable.  *Note Settings::.)

   For the next example, we will demonstrate a _conditional_ property:
the successor of any even number should be odd.

     val succ_even_odd = even ==> odd o succ
      ⊣ val succ_even_odd =

     checkGen int ("even+1=odd", succ_even_odd);
      ⊣ : int prop
      ⊣ even+1=odd.............ok      (100 passed)
      ⊣ val it = () : unit

In this example, the 100 test cases that passed were all ones that met
the condition: they were all even.  Odd numbers trivially satisfy the
property (by falsifying the condition) and are not counted.

   Now, let's try the inverse property: the successor of an odd number
should be even:

     checkGen int ("odd+1=even", odd ==> even o succ);
      ⊣ odd+1=even.............ok      (17 passed)         Shrinking...
      ⊣ odd+1=even.............FAILED  (39/40 passed)      Shrinking...
      ⊣ odd+1=even.............FAILED  (66/68 passed)      Shrinking...
      ⊣ odd+1=even.............FAILED  (93/96 passed)      Shrinking...
      ⊣ odd+1=even.............FAILED  (94/98 passed)      Shrinking...
      ⊣ odd+1=even.............FAILED  (95/100 passed)
      ⊣       counter-examples:       1073741823
      ⊣                               1073741823
      ⊣                               1073741823
      ⊣                               1073741823
      ⊣ val it = () : unit

Oops!  QCheck found a counter-example: the maximum 31-bit integer.  It
is odd, but since its successor is undefined, the property does not
hold.  (We were not extraordinarily lucky to generate `maxInt` this time
around; in fact, the generator is biased so that zero, `minInt`, and
`maxInt` are chosen more frequently than other integers, precisely
because they are often "boundary conditions."  *Note Generating test
cases::.)

   At any rate, what is broken here is not really our implementation,
but rather the specification of the property.  We need to limit it to
odd integers that are less than `maxInt`.

     fun odd_not_max x = odd x andalso x < valOf(Int.maxInt);
     checkGen int ("odd+1=even", odd_not_max ==> even o succ)
      ⊣ val odd_not_max = fn : int → bool
      ⊣ odd+1=even.............ok      (100 passed)
      ⊣ val it = () : unit

1.2 Generating pairs of integers
================================

Other properties involve pairs of integers.  For example, the sum of two
odd numbers is even.

     fun both_odd(x,y) = odd x andalso odd y
     fun sum_even(x,y) = even (x+y)
     fun show_pair(x,y) = Int.toString x ^","^ Int.toString y
      ⊣ val both_odd = fn : int * int → bool
      ⊣ val sum_even = fn : int * int → bool
      ⊣ val show_pair = fn : int * int → string

QCheck includes not only generators for most primitive and aggregate
data types, but also functions for combining them in various ways.  To
generate random pairs of integers, we "zip" together two integer
generators.

     checkGen (Gen.zip(Gen.Int.int, Gen.Int.int), SOME show_pair)
              ("odd+odd=even", both_odd ==> sum_even)
      ⊣ odd+odd=even...........ok      (80 passed)         Shrinking...
      ⊣ odd+odd=even...........FAILED  (99/100 passed)
      ⊣       counter-examples:       1073741823,329
      ⊣ val it = () : unit

All of the counter-examples overflow the sum computation.  I'll leave
fixing this specification as an exercise for the reader.

   Test cases need not be randomly generated.  Here is an example where
the pairs will be taken from a list, but they could just as easily be
read from a file.  *Note Specifying test cases::.

     check (List.getItem, SOME show_pair)
           ("sum_odds_even[]", both_odd ==> sum_even)
           [(1,1), (3,5), (3,4), (* this one won't count! *)
            (~1,1), (21,21), (7,13)]
      ⊣ sum_odds_even[]........ok      (5 passed)
      ⊣ val it = () : unit

I provided 6 pairs in the list, but only 5 counted because `(3,4)` did
not meet the precondition of the property.

1.3 The QCheck structure
========================

The examples in the preceding sections used several top-level functions
from the `QCheck` structure.  Here, we will examine the signature of
`QCheck`, beginning with its sub-structures.

     structure Gen : GENERATOR_SIG
     structure Files : FILES_SIG
     structure Settings : SETTINGS_SIG
The `Gen` structure contains random value generators for all the basis
types, including aggregates like vectors and lists.  It also contains a
rich library of combinators such as `zip`, `map`, and `filter`.  *Note
Generating test cases::.

   `Files` is provided to make it easy to use lines in a file or files
in a directory as test cases.  *Note Specifying test cases::.
`Settings` contains various user-customizable settings, including
user-definable output styles.  *Note Settings::.

     include PROPERTY_SIG
This signature contains functions for specifying properties and
observing the distribution of test cases.  In preceding sections, we met
two of its members: `pred` converts a predicate (boolean function) on a
given type to a property, and `==>` creates a conditional property.  A
property over a given type `t` has type `t prop`.  *Note Properties::.

Two types are useful for discussing the parameters of the various
`check` functions:

     type (α,β) reader = β → (α * β) option
     type α rep = (α → string) option
An `(α,β) reader` pulls objects of type `α` from a stream of type
`β`.  In this case, the objects are test cases of some type.  (This is
defined the same way as `StringCvt.reader`.)  The type `α rep` is an
(optional) method for rendering test cases as strings.  It is used in
case there are counter-examples to be printed.

Now, the most general function for invoking QCheck is called `check`.
It takes 3 (curried) parameters:

     val check : (α,β) reader * α rep →
                 string * α prop →
                 β → unit
  1. The first parameter is a reader and representation pair.  It
     contains everything the checker needs to know about the type of the
     test cases, and the same pair can be reused to check additional
     properties of the same type.

  2. Next is the property name and specification.  This parameter will
     be different for each property checked.  The name is just a string
     used to distinguish the results of this test in the output.

  3. Finally, you provide a stream of test cases.  The source of the
     test cases is arbitrary, as long as a matching reader is provided.
     They could be randomly generated, read from a data structure,
     extracted from the file system, etc.

We provide several specializations of `check` that are useful in
particular circumstances.  First, `checkGen` is for checking randomly
generated test cases.  The random number stream is implicit, and the
reader is always a generator from the `Gen` module.

     val checkGen : α Gen.gen * α rep →
                    string * α prop → unit

   Second, if we just want to check one particular test case, the reader
is trivial (and therefore omitted), and the `stream` is just the test
case itself:

     val checkOne : α rep → string * α prop → α → unit

   Third, if we want to provide a shrinking function, QCheck will try to
find a smaller counterexample:

     val checkGenShrink : (α → α list) → α Gen.gen * α rep →
                          string * α prop → unit

   Fourth, if we want to use the checker as an API, we can pass a
continuation that takes a list of bad objects and some stats.

     val cpsCheck :
         (α → α list)
         → Property.stats
         → (α, σ) reader * α rep
         → α prop
         → (string option * Property.result * Property.stats → unit)
         → (α list → Property.stats → β)
         → σ
         → β

   Finally, the `Qcheck` structure includes a pair `version` that can be
useful in determining the version of QCheck you are using.  The
`context` contains expanded version information that can be used by
darcs to reconstruct this precise configuration of QCheck.

     val version : int * int
     val context : string

The version information currently reported by `QCheck.version` is:

     QCheck.version;
      ⊣ val it = (1,2) : int * int
