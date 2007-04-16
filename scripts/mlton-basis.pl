#! /usr/bin/perl
use strict;

while(<>)
{
    chop;
    if(/^structure (\w*Int(\d+)?(Inf)?\b)/ && (!$2 || $2 > 3) ||
       /^structure (\w*Word\d*\b)/ ||
       /^structure (\w+)\s*:\s*REAL\b/ ||
       /^structure (\w+)\s*:\s*TEXT\b/ && $1 ne 'Text')
    {
        print "$1\n";
    }
}

