(* styles/perl.sml -- similar to the output of Perl unit tests
 * Copyright ©2007 Christopher League <league@contrapunctus.net>
 * 
 * This library is free software; you may redistribute and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; see the file COPYING. 
 *)

structure PerlStyle =
struct

open StringCvt
val int = Int.toString

fun op<< (os, f) = f os
fun put str os = os before TextIO.output(os, str)
fun flush os = os before TextIO.flushOut os
fun return x os = x
fun keep str L = str::L
fun ends L = String.concat (rev L)
infix <<

(*       1         2  |        |         1         2|         1         2
1234567890123456789012|12345678|12345678901234567890|1234567890123456789012345
Bool/to-from..........|ok      |(100 passed)        | 32% trivial
                      |        |                    |100% misleading
Bool/from-to..........|dubious |(0/0 passed)        |
Bool/invalid..........|ok      |(96 passed)         |
Bool/valid............|FAILED  |(9999/9999 passed)  |
         counter-examples:       blah
                         :       blah
 *)

fun new tag =
let
    val errs = ref nil
    val sort = Settings.get Settings.sort_examples
    fun addErr obj =
      let fun errsize NONE = 999999
            | errsize (SOME s) = size s
          fun insert [] = [obj]
            | insert (err::errs) =
                if errsize obj <= errsize err then obj :: err :: errs
                else err :: insert errs
      in  errs := insert (!errs)
      end

    fun addErrNosort obj = errs := obj :: (!errs)

    val addErr = if sort then addErr else addErrNosort

    val os = Settings.get Settings.outstream
    val namew = Settings.get Settings.column_width
    val resultw = 8
    val countw = 20
    val allw = namew + resultw + countw + 2

    fun resultStr _ {count=0,...} = "dubious"
      | resultStr false (_ : Property.stats) = 
        if null(!errs) then "ok"
        else "FAILED"
      | resultStr true {count,tags,...}  = 
        if not(null(!errs)) then "FAILED"
        else case (StringBag.member(tags, "__GEN"), 
                   Settings.get Settings.gen_target)
               of (true, SOME target) =>
                  if count < target then "dubious" else "ok"
                | _ => "ok"

    fun countStr 0 = "(0/0 passed)"
      | countStr count = 
        case length(!errs)
          of 0 => nil << keep "(" << keep (int count) 
                      << keep " passed)" << ends
           | n => nil << keep "(" << keep (int (count-n))
                      << keep "/" << keep (int count)
                      << keep " passed)" << ends

    fun update stats donep os =
        os << put "\r"
           << put (padRight #"." namew tag) << put "."
           << put (padRight #" " resultw (resultStr donep stats))
           << put (padRight #" " countw (countStr (#count stats)))
           << flush

    fun status (obj, result, stats) =
        (if Property.failure result then addErr obj
         else();
         os << update stats false << return())

    fun prtag count (tag,n,(os,first)) = 
        if String.isPrefix "__" tag then (os, first)
        else let val ratio = real n / real count
                 val ratio = round(ratio * 100.0)
                 val ratio = padLeft #" " 3 (int ratio)
              in (os << put (if first then "" else padRight #" " allw "\n")
                     << put ratio << put "% "
                     << put tag,
                  false)
             end
    fun prtags ({count,tags,...} : Property.stats) os =
        if Settings.get Settings.show_stats then
            #1(StringBag.foldli (prtag count) (os, true) tags)
        else os

    fun err os = 
        let val limit = 4
            fun iter nil _ os = os
              | iter(NONE::es) k os = os << iter es k
              | iter(SOME e::es) k os = 
                if k >= limit then os
                else os << put (padLeft #" " namew (if k>0 then ""
                                                    else "counter-examples"))
                        << put (padRight #" " resultw (if k>0 then "" else ":"))
                        << put e
                        << put "\n"
                        << iter es (k+1)
         in iter(!errs) 0 os
        end

    fun finish stats =
        if null(!errs) then
            os << update stats true << prtags stats << put "\n" << return true
        else
            os << update stats true << put "\n" << err << return false

 in {status=status, finish=finish}
end

val style = {name="Perl", ctor=new}

end
