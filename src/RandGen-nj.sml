(* RandGen.sml -- instantiate functiors to Basis types in SML/NJ
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
    structure Int31     = GenInt (open Gen structure Int = Int31)
    structure Int32     = GenInt (open Gen structure Int = Int32)
    structure Int64     = GenInt (open Gen structure Int = Int64)
    structure LargeInt  = GenInt (open Gen structure Int = LargeInt)
    structure Position  = GenInt (open Gen structure Int = Position)
    structure IntInf    = GenInt (open Gen structure Int = IntInf)

    structure Real      = GenReal(open Gen structure Real = Real)
    structure Real64    = GenReal(open Gen structure Real = Real64)
    structure LargeReal = GenReal(open Gen structure Real = LargeReal)

    structure Word      = GenWord(open Gen structure Word = Word)
    structure Word8     = GenWord(open Gen structure Word = Word8)
    structure Word31    = GenWord(open Gen structure Word = Word31)
    structure Word32    = GenWord(open Gen structure Word = Word32)
    structure Word64    = GenWord(open Gen structure Word = Word64)
    structure LargeWord = GenWord(open Gen structure Word = LargeWord)
    structure SysWord   = GenWord(open Gen structure Word = SysWord)

    structure DateTime = GenDateTime(Gen)

    open Gen
    val stream = start (R.new())
  end
    type rand = R.rand
    type 'a gen = rand -> 'a * rand
    type ('a, 'b) co = 'a -> 'b gen -> 'b gen
end

structure RandGen = GeneratorFn(Rand)
