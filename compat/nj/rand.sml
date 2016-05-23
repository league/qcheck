(* gen/random.sml -- instantiate generators using applicative RNG
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 *
 * This library is free software; see the LICENSE file.
 *)

structure Rand' =
struct
    type rand = Rand.rand
    val new = Word.fromLargeInt o Time.toMilliseconds o Time.now
    fun range (x,y) r =
        (Rand.range (x,y) r,
         Rand.random r)
    val mask = 0wx3afebabe
    fun salt w s = Word.>>(Word.xorb(w,s), 0w1)
    fun split r =
        (salt r mask,
         salt r (Word.notb mask))
end
