(* gen/random.sml -- instantiate generators using applicative RNG
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure Rand' = 
struct
    val _ = Word.wordSize = 31 orelse raise Fail "Word size <> 31"
    val _ = Int.precision = SOME 31 orelse raise Fail "Int size <> 31"

    type rand = Word.word
    type rand' = Int.int  (* internal representation *)

    val new = Word.fromLargeInt o Time.toMilliseconds o Time.now

    val a : rand' = 48271
    val m : rand' = 2147483647  (* 2^31 - 1 *)
    val m_1 = m - 1
    val q = m div a
    val r = m mod a

    val extToInt = Int32.fromLarge o Word31.toLargeInt
    val intToExt = Word31.fromLargeInt o Int32.toLarge

    val randMin : rand = 0w1
    val randMax : rand = intToExt m_1

    fun chk 0w0 = 1
      | chk 0wx7fffffff = m_1
      | chk seed = extToInt seed

    fun random' seed = let 
          val hi = seed div q
          val lo = seed mod q
          val test = a * lo - r * hi
          in
            if test > 0 then test else test + m
          end

    val random = intToExt o random' o chk

    fun mkRandom seed = let
          val seed = ref (chk seed)
          in
            fn () => (seed := random' (!seed); intToExt (!seed))
          end

    val real_m = Real.fromLargeInt (Int32.toLarge m)
    fun norm s = (Real.fromLargeInt (Word31.toLargeInt s)) / real_m

    fun range (i,j) = 
          if j < i 
            then LibBase.failure{module="Random",func="range",msg="hi < lo"}
          else if j = i then fn _ => i
          else let 
            val R = Int32.fromInt j - Int32.fromInt i
            val cvt = Word31.toIntX o Word31.fromLargeInt o Int32.toLarge
            in
              if R = m then Word31.toIntX
              else fn s => i + cvt ((extToInt s) mod (R+1))
            end

    fun split r =
        let val r = r / a
            val r0 = real(floor r)
            val r1 = r - r0
         in (nextrand r0, nextrand r1)
        end
end

