(* gen/gen.sml -- instantiate all the functors to basis types
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

functor GeneratorFn(R : APPLICATIVE_RNG) : GENERATOR =
struct
  local 
    structure Gen = BaseGeneratorFn(R)
    structure Gen = GenText(structure Gen=Gen structure Text=Text)
  in
    structure Int    = GenInt (open Gen structure Int = Int)
    structure Int32  = GenInt (open Gen structure Int = Int32)
    structure IntInf = GenInt (open Gen structure Int = IntInf)
    structure Word   = GenWord(open Gen structure Word = Word)
    structure Word8  = GenWord(open Gen structure Word = Word8)
    structure Word32 = GenWord(open Gen structure Word = Word32)
    structure Real   = GenReal(open Gen structure Real = Real)
    structure DateTime = GenDateTime(Gen)
 (* It should be ok to add the following once WideText is available...
    structure WideText = GenText(open Gen structure Text=WideText)
  *)
    open Gen
    val stream = start (R.seed(Time.now()))
  end
    type rand = R.rand
    type 'a gen = rand -> 'a * rand
    type ('a, 'b) co = 'a -> 'b gen -> 'b gen
end

