#! /usr/bin/perl
use strict;

my $example = 0;
my $text = 0;

while(<>)
{
    chop;
    if(/^\(\*<<\*\)/) 
    { 
        $example = 1; 
        print "\@example\n";
    }
    elsif(/^\(\*>>\*\)/) 
    { 
        $example = 0; 
        print "\@end example\n";
    }
    elsif(/^(.*)\(\*(\@[a-z]+index .*)\*\)\s*$/)
    {
        print nl($1)."$2\n";
    }
    elsif(/^(.*)\(\*\@(.*)\*\)(.*)$/) 
    {
        print nl($1)."\@end example\n" if $example;
        print "$2\n";
        print "\@example\n".nl($3) if $example;
    }
    elsif(/^(.*)\(\*\@(.*)$/)
    {
        print nl($1)."\@end example\n\@noindent\n" if $example;
        print "$2\n";
        $text = 1;
    }
    elsif($text and /^(.*)\*\)(.*)$/)
    {
        $text = 0;
        print "$1\n";
        print "\@example\n".nl($2) if $example
    }
    else
    {
        if($text) { print "$_\n"; }
        elsif($example) { print protect($_)."\n"; }
    }
}
exit 0;

sub nl {
    my($chunk) = @_;
    if($chunk =~ /^\s*$/) { return ""; }
    else { return protect($chunk)."\n"; }
}

sub protect {
    my($chunk) = @_;
    $chunk =~ s/\{/\@\{/g;
    $chunk =~ s/\}/\@\}/g;
    return $chunk;
}
