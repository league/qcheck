(* GENERATOR_SIG.sml -- Basis modules generators for SML/NJ
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

signature GENERATOR_SIG =
sig include TEXT_GENERATOR
    val stream : stream
    structure DateTime : DATE_TIME_GENERATOR

    structure Int : INT_GENERATOR
    structure Int31 : INT_GENERATOR
    structure Int32 : INT_GENERATOR
    structure Int64 : INT_GENERATOR
    structure LargeInt : INT_GENERATOR
    structure Position : INT_GENERATOR
    structure IntInf : INT_GENERATOR

    structure Real : REAL_GENERATOR
    structure Real64 : REAL_GENERATOR
    structure LargeReal : REAL_GENERATOR

    structure Word : WORD_GENERATOR
    structure Word8 : WORD_GENERATOR
    structure Word31 : WORD_GENERATOR
    structure Word32 : WORD_GENERATOR
    structure Word64 : WORD_GENERATOR
    structure LargeWord : WORD_GENERATOR
    structure SysWord : WORD_GENERATOR

end
