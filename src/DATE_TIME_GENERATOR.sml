signature DATE_TIME_GENERATOR =
sig include GEN_TYPES
(*<<*)
(*@findex DateTime structure *)
(*@ Generate dates and times from @code{Gen.DateTime}.  The
@code{dateFromYear} function uses the given generator to produce
the year, but then it comes up with a month, day, hour, minute,
and second itself.  A few days are more likely than others because
we do not bother to generate the correct number of days based on the
month.  This makes May 1st more likely than May 2nd, because it could
also have been generated as April 31st.  (The Basis @code{Date.date}
normalizes the dates though, so you will never see April 31st.) *)
(*@findex weekday*)
val weekday : Date.weekday gen              
(*@findex month*)
val month : Date.month gen                  
(*@findex dateFromYear*)
val dateFromYear : int gen -> Date.date gen 
(*@findex time*)
val time : Time.time gen                    
(*>>*)
val dateFromUTC : Date.date gen  (* broken? *)
end
