#! /usr/bin/perl
use strict;

my $example = 0;
my $text = 0;

while(<>)
{
    chop;
    if(/^\(\*<<\*\)/)           # start extracting
    { 
        $example = 1; 
        print "\@example\n";
    }
    elsif(/^\(\*>>\*\)/)        # finish extracting
    { 
        $example = 0; 
        print "\@end example\n";
    }
    elsif(/^(.*)\(\*(\@[a-z]+index .*)\*\)\s*$/) # index this line
    {
        print nl($1)."$2\n";
    }
    elsif(/^(.*)\(\*\@(.*)\*\)(.*)$/) # one line of text
    {
        print nl($1)."\@end example\n" if $example;
        print "$2\n";
        print "\@example\n".nl($3) if $example;
    }
    elsif(/^(.*)\(\*\@(.*)$/)   # start of text
    {
        print nl($1)."\@end example\n\@noindent\n" if $example;
        print "$2\n";
        $text = 1;
    }
    elsif($text and /^(.*)\*\)(.*)$/) # end of text
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
    # protect braces
    $chunk =~ s/\{/\@\{/g;
    $chunk =~ s/\}/\@\}/g;
    # highlight keywords
    $chunk =~ s/^(\s*)(val|type|structure)\b/$1\@b\{$2\}/;
    return $chunk;
}
