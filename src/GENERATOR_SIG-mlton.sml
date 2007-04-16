(* GENERATOR_SIG.sml -- Basis modules generators for MLton
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
    structure LargeInt : INT_GENERATOR
    structure Position : INT_GENERATOR
    structure IntInf : INT_GENERATOR

    (* Wow, I dig the completeness of fixed-size values in MLton.
       GenInt needs at least 3 bits to work correctly though.  Just
       for reference, those marked also have monomorphic vector and
       array modules. *)

    structure Int3 : INT_GENERATOR
    structure Int4 : INT_GENERATOR
    structure Int5 : INT_GENERATOR
    structure Int6 : INT_GENERATOR
    structure Int7 : INT_GENERATOR
    structure Int8 : INT_GENERATOR (**)
    structure Int9 : INT_GENERATOR
    structure Int10 : INT_GENERATOR
    structure Int11 : INT_GENERATOR
    structure Int12 : INT_GENERATOR
    structure Int13 : INT_GENERATOR
    structure Int14 : INT_GENERATOR
    structure Int15 : INT_GENERATOR
    structure Int16 : INT_GENERATOR (**)
    structure Int17 : INT_GENERATOR
    structure Int18 : INT_GENERATOR
    structure Int19 : INT_GENERATOR
    structure Int20 : INT_GENERATOR
    structure Int21 : INT_GENERATOR
    structure Int22 : INT_GENERATOR
    structure Int23 : INT_GENERATOR
    structure Int24 : INT_GENERATOR
    structure Int25 : INT_GENERATOR
    structure Int26 : INT_GENERATOR
    structure Int27 : INT_GENERATOR
    structure Int28 : INT_GENERATOR
    structure Int29 : INT_GENERATOR
    structure Int30 : INT_GENERATOR
    structure Int31 : INT_GENERATOR
    structure Int32 : INT_GENERATOR (**)
    structure Int64 : INT_GENERATOR (**)

    structure Real : REAL_GENERATOR
    structure Real32 : REAL_GENERATOR
    structure Real64 : REAL_GENERATOR
    structure LargeReal : REAL_GENERATOR

    structure Word : WORD_GENERATOR
    structure LargeWord : WORD_GENERATOR
    structure SysWord : WORD_GENERATOR

    structure Word1 : WORD_GENERATOR
    structure Word2 : WORD_GENERATOR
    structure Word3 : WORD_GENERATOR
    structure Word4 : WORD_GENERATOR
    structure Word5 : WORD_GENERATOR
    structure Word6 : WORD_GENERATOR
    structure Word7 : WORD_GENERATOR
    structure Word8 : WORD_GENERATOR (**)
    structure Word9 : WORD_GENERATOR
    structure Word10 : WORD_GENERATOR
    structure Word11 : WORD_GENERATOR
    structure Word12 : WORD_GENERATOR
    structure Word13 : WORD_GENERATOR
    structure Word14 : WORD_GENERATOR
    structure Word15 : WORD_GENERATOR
    structure Word16 : WORD_GENERATOR (**)
    structure Word17 : WORD_GENERATOR
    structure Word18 : WORD_GENERATOR
    structure Word19 : WORD_GENERATOR
    structure Word20 : WORD_GENERATOR
    structure Word21 : WORD_GENERATOR
    structure Word22 : WORD_GENERATOR
    structure Word23 : WORD_GENERATOR
    structure Word24 : WORD_GENERATOR
    structure Word25 : WORD_GENERATOR
    structure Word26 : WORD_GENERATOR
    structure Word27 : WORD_GENERATOR
    structure Word28 : WORD_GENERATOR
    structure Word29 : WORD_GENERATOR
    structure Word30 : WORD_GENERATOR
    structure Word31 : WORD_GENERATOR
    structure Word32 : WORD_GENERATOR (**)
    structure Word64 : WORD_GENERATOR (**)

end
