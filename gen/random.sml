(* gen/random.sml -- instantiate generators using applicative RNG
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure Rand' = 
struct
    type rand = Rand.rand
    val seed = Word.fromLargeInt o Time.toMilliseconds
    fun range (x,y) r = 
        (Rand.range (x,y) r,
         Rand.random r)
    val mask = 0wx3afebabe
    fun salt w s = Word.>>(Word.xorb(w,s), 0w1)
    fun split r = 
        (salt r mask, 
         salt r (Word.notb mask))
end

structure RandGen = GeneratorFn(Rand')


