(* gen/date.sml -- generate random dates and times
 * Copyright ©2004 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

functor GenDateTime (Gen : TEXT_GENERATOR) : DATE_TIME_GENERATOR =
struct

open Gen Date

val weekday = select #[Mon, Tue, Wed, Thu, Fri, Sat, Sun]
val month = select #[Jan, Feb, Mar, Apr, May, Jun, 
                     Jul, Aug, Sep, Oct, Nov, Dec]

fun dateFromYear year r = 
    let val (Y,r) = year r
        val (M,r) = month r
        val (D,r) = range(1,31) r
        val (h,r) = range(0,23) r
        val (m,r) = range(0,59) r
        val (s,r) = range(0,59) r
     in (Date.date {year=Y, month=M, day=D, offset=NONE,
                    hour=h, minute=m, second=s},
         r)
    end

structure LG = GenInt(open Gen
                      structure Int = LargeInt)

val time = map Time.fromMilliseconds LG.int

(* doesn't work very well.. way biased towards 1970. *)
fun dateFromUTC r = 
    let val (t,r) = time r
     in print ("Trying: "^Time.toString t^"\n")
      ; (Date.fromTimeUniv t, r)
        handle Overflow => dateFromUTC r
    end

end
