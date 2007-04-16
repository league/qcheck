(* GENERATOR_SIG.sml -- Basis modules generators for Moscow ML
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
    structure Word : WORD_GENERATOR
    structure Word8 : WORD_GENERATOR
end
