(* gen/gen.sml -- instantiate all the functors to basis types
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

signature GENERATOR =
sig include TEXT_GENERATOR
    structure Int : INT_GENERATOR
    structure Word : WORD_GENERATOR
    structure Word8 : WORD_GENERATOR
    structure DateTime : DATE_TIME_GENERATOR
    val stream : stream
end

functor GeneratorFn(R : APPLICATIVE_RNG) : GENERATOR =
struct
  local 
    structure Gen = BaseGeneratorFn(R)
    structure Gen = GenText(structure Gen=Gen structure Text=Text)
  in
    structure Int    = GenInt (open Gen structure Int = Int)
    structure Word   = GenWord(open Gen structure Word = Word)
    structure Word8  = GenWord(open Gen structure Word = Word8')
    structure DateTime = GenDateTime(Gen)
    open Gen
    val stream = start (R.new())
  end
    type rand = R.rand
    type 'a gen = rand -> 'a * rand
    type ('a, 'b) co = 'a -> 'b gen -> 'b gen
end

structure RandGen = GeneratorFn(Rand')
