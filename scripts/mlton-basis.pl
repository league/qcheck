#! /usr/bin/perl
use strict;

open(SIG, '>src/GENERATOR_SIG-mlton.sml') or die 'cannot write sig';
open(GEN, '>src/RandGen-mlton.sml') or die 'cannot write gen';

print SIG <<EOF;
(* DO NOT EDIT -- Generated by mlton-basis.pl *)
  signature GENERATOR_SIG = sig
  include TEXT_GENERATOR
  val stream : stream
  structure DateTime : DATE_TIME_GENERATOR
EOF

print GEN <<EOF;
(* DO NOT EDIT -- Generated by mlton-basis.pl *)
  functor GeneratorFn(R : APPLICATIVE_RNG) : GENERATOR_SIG =
  struct
    local
      structure Gen = BaseGeneratorFn(R)
      structure Gen = GenText(structure Gen=Gen structure Text=Text)
    in 
EOF

while(<>)
{
    chop;
    if(/^structure (\w*Int(\d+)?(Inf)?\b)/ &&
       (!$2 || $2 > 3))
    {
        print SIG "structure $1 : INT_GENERATOR\n";
        print GEN "structure $1 = GenInt(open Gen structure Int = $1)\n";
    }
    elsif(/^structure (\w*Word\d*\b)/)
    {
        print SIG "structure $1 : WORD_GENERATOR\n";
        print GEN "structure $1 = GenWord(open Gen structure Word = $1)\n";
    }
    elsif(/^structure (\w+)\s*:\s*REAL\b/)
    {
        print SIG "structure $1 : REAL_GENERATOR\n";
        print GEN "structure $1 = GenReal(open Gen structure Real = $1)\n";
    }
    elsif(/^structure (\w+)\s*:\s*TEXT\b/ && $1 ne 'Text')
    {
        print SIG "structure $1 : TEXT_GENERATOR\n";
        print GEN "structure $1 = GenText(structure Gen=Gen structure Text=$1)\n";
    }
}

print SIG "end\n";

print GEN <<EOF;
    structure DateTime = GenDateTime(Gen)
    open Gen
    val stream = start (R.new())
  end (* local *)
  type rand = R.rand
  type 'a gen = rand -> 'a * rand
  type ('a, 'b) co = 'a -> 'b gen -> 'b gen
end
structure RandGen = GeneratorFn(Rand)
EOF

close(SIG);
close(GEN);