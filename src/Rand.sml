
structure Rand =
struct

type rand = real

val a = 16807.0
val m = 2147483647.0

fun nextrand seed =
    let val t = a * seed
     in t - m * real(floor(t/m))
    end

val new = nextrand o Time.toReal o Time.now

fun range (min, max) =
    if min > max then raise Domain
    else fn r =>
            (min + (floor(real(max-min+1) * r / m)),
             nextrand r)

fun split r =
    let val r = r / a
        val r0 = real(floor r)
        val r1 = r - r0
     in (nextrand r0, nextrand r1)
    end

end
