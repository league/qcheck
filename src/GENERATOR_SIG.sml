(* GENERATOR_SIG.sml -- Basis modules generators for Poly/ML
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

 (* Int, LargeInt and Position are the same structure and provide
    operations on type int.  In Poly/ML that is an arbitrary precision
    integer.  Poly/ML does not support any fixed precision integers.
    IntInf provides additional functions, such as logical operations
    on integers.  <http://www.polyml.org/docs/StandBasis.html> *)

    structure Int : INT_GENERATOR
    structure LargeInt : INT_GENERATOR
    structure Position : INT_GENERATOR
    structure IntInf : INT_GENERATOR

 (* Real and LargeReal are the same structure in Poly/ML.  They
    provide functions on type real. *)

    structure Real : REAL_GENERATOR
    structure LargeReal : REAL_GENERATOR

 (* Operations on machine words treated as unsigned quantities.
    Functions which would overflow simply wrap round.  Poly/ML
    implements Word.word as 31 bit quantity on the i386 and PPC and a
    30 bit quantity on the Sparc.  LargeWord and SysWord implement a
    double precision version used in the Windows and Posix structures.
    Word8.word is an unsigned byte. *)

    structure Word : WORD_GENERATOR
    structure Word8 : WORD_GENERATOR
    structure LargeWord : WORD_GENERATOR
    structure SysWord : WORD_GENERATOR

end
