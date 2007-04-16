(* RandGen.sml -- instantiate functiors to Basis types in Moscow ML
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

functor GeneratorFn(R : APPLICATIVE_RNG) : GENERATOR_SIG =
struct
  local 
    structure Gen = BaseGeneratorFn(R)
    structure Gen = GenText(structure Gen=Gen structure Text=Text)
  in
    structure Int       = GenInt (open Gen structure Int = Int)
    structure LargeInt  = GenInt (open Gen structure Int = LargeInt)

    structure Word      = GenWord(open Gen structure Word = Word)
    structure Word8     = GenWord(open Gen structure Word = Word8)

    structure DateTime = GenDateTime(Gen)

    open Gen
    val stream = start (R.new())
  end
    type rand = R.rand
    type 'a gen = rand -> 'a * rand
    type ('a, 'b) co = 'a -> 'b gen -> 'b gen
end

structure RandGen = GeneratorFn(Rand)
