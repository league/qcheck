(* RandGen.sml -- instantiate functiors to Basis types in MLton
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
    structure Int = GenInt(open Gen structure Int = Int)
    structure LargeInt = GenInt(open Gen structure Int = LargeInt)
    structure Position = GenInt(open Gen structure Int = Position)
    structure IntInf = GenInt(open Gen structure Int = IntInf)

    structure Int3 = GenInt(open Gen structure Int = Int3)
    structure Int4 = GenInt(open Gen structure Int = Int4)
    structure Int5 = GenInt(open Gen structure Int = Int5)
    structure Int6 = GenInt(open Gen structure Int = Int6)
    structure Int7 = GenInt(open Gen structure Int = Int7)
    structure Int8 = GenInt(open Gen structure Int = Int8)
    structure Int9 = GenInt(open Gen structure Int = Int9)
    structure Int10 = GenInt(open Gen structure Int = Int10)
    structure Int11 = GenInt(open Gen structure Int = Int11)
    structure Int12 = GenInt(open Gen structure Int = Int12)
    structure Int13 = GenInt(open Gen structure Int = Int13)
    structure Int14 = GenInt(open Gen structure Int = Int14)
    structure Int15 = GenInt(open Gen structure Int = Int15)
    structure Int16 = GenInt(open Gen structure Int = Int16)
    structure Int17 = GenInt(open Gen structure Int = Int17)
    structure Int18 = GenInt(open Gen structure Int = Int18)
    structure Int19 = GenInt(open Gen structure Int = Int19)
    structure Int20 = GenInt(open Gen structure Int = Int20)
    structure Int21 = GenInt(open Gen structure Int = Int21)
    structure Int22 = GenInt(open Gen structure Int = Int22)
    structure Int23 = GenInt(open Gen structure Int = Int23)
    structure Int24 = GenInt(open Gen structure Int = Int24)
    structure Int25 = GenInt(open Gen structure Int = Int25)
    structure Int26 = GenInt(open Gen structure Int = Int26)
    structure Int27 = GenInt(open Gen structure Int = Int27)
    structure Int28 = GenInt(open Gen structure Int = Int28)
    structure Int29 = GenInt(open Gen structure Int = Int29)
    structure Int30 = GenInt(open Gen structure Int = Int30)
    structure Int31 = GenInt(open Gen structure Int = Int31)
    structure Int32 = GenInt(open Gen structure Int = Int32)
    structure Int64 = GenInt(open Gen structure Int = Int64)

    structure Real = GenReal(open Gen structure Real = Real)
    structure Real32 = GenReal(open Gen structure Real = Real32)
    structure Real64 = GenReal(open Gen structure Real = Real64)
    structure LargeReal = GenReal(open Gen structure Real = LargeReal)

    structure Word      = GenWord(open Gen structure Word = Word)
    structure LargeWord = GenWord(open Gen structure Word = LargeWord)
    structure SysWord   = GenWord(open Gen structure Word = SysWord)

    structure Word1 = GenWord(open Gen structure Word = Word1)
    structure Word2 = GenWord(open Gen structure Word = Word2)
    structure Word3 = GenWord(open Gen structure Word = Word3)
    structure Word4 = GenWord(open Gen structure Word = Word4)
    structure Word5 = GenWord(open Gen structure Word = Word5)
    structure Word6 = GenWord(open Gen structure Word = Word6)
    structure Word7 = GenWord(open Gen structure Word = Word7)
    structure Word8 = GenWord(open Gen structure Word = Word8)
    structure Word9 = GenWord(open Gen structure Word = Word9)
    structure Word10 = GenWord(open Gen structure Word = Word10)
    structure Word11 = GenWord(open Gen structure Word = Word11)
    structure Word12 = GenWord(open Gen structure Word = Word12)
    structure Word13 = GenWord(open Gen structure Word = Word13)
    structure Word14 = GenWord(open Gen structure Word = Word14)
    structure Word15 = GenWord(open Gen structure Word = Word15)
    structure Word16 = GenWord(open Gen structure Word = Word16)
    structure Word17 = GenWord(open Gen structure Word = Word17)
    structure Word18 = GenWord(open Gen structure Word = Word18)
    structure Word19 = GenWord(open Gen structure Word = Word19)
    structure Word20 = GenWord(open Gen structure Word = Word20)
    structure Word21 = GenWord(open Gen structure Word = Word21)
    structure Word22 = GenWord(open Gen structure Word = Word22)
    structure Word23 = GenWord(open Gen structure Word = Word23)
    structure Word24 = GenWord(open Gen structure Word = Word24)
    structure Word25 = GenWord(open Gen structure Word = Word25)
    structure Word26 = GenWord(open Gen structure Word = Word26)
    structure Word27 = GenWord(open Gen structure Word = Word27)
    structure Word28 = GenWord(open Gen structure Word = Word28)
    structure Word29 = GenWord(open Gen structure Word = Word29)
    structure Word30 = GenWord(open Gen structure Word = Word30)
    structure Word31 = GenWord(open Gen structure Word = Word31)
    structure Word32 = GenWord(open Gen structure Word = Word32)
    structure Word64 = GenWord(open Gen structure Word = Word64)

    structure DateTime = GenDateTime(Gen)

    open Gen
    val stream = start (R.new())
  end
    type rand = R.rand
    type 'a gen = rand -> 'a * rand
    type ('a, 'b) co = 'a -> 'b gen -> 'b gen
end

structure RandGen = GeneratorFn(Rand)
