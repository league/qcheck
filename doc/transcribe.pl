#! /usr/bin/perl
use strict;
use Expect;

my $cmd = shift @ARGV;

$Expect::Log_Stdout = 0;
my $ml = new Expect;
$ml->raw_pty(1);
$ml->spawn($cmd, @ARGV)
    or die "Cannot spawn $cmd: $!\n";
$ml->expect(undef, '-re', '- ');
my $line = 0;
while(<STDIN>)
{
    print "\@c THIS FILE IS AUTO-GENERATED; DO NOT EDIT!\n"
        if $line++ == 1 or /^\@node/;
    if(/^\@transcript/) 
    {
        my $verbosity = 2;
        $verbosity = 1 if /quiet/;  # show input only, ignore output
        $verbosity = 0 if /omit/;   # omit entire block, just pipe to ML
        print "\@example\n" if $verbosity > 0;
        while(<STDIN>)
        {
            last if /^\@end transcript/;
            print $_ if $verbosity > 0;
            $ml->send($_);
            $ml->expect(undef, '-re', '^[=-] ');
            render_output($ml->before()) if $verbosity > 1;
        }
        $ml->send(";\n");
        $ml->expect(undef, '-re', '^- ');
        render_output($ml->before()) if $verbosity > 1;
        print "\@end example\n" if $verbosity > 0;
    }
    else { print; }
}
$ml->send(($cmd =~ /mosml$/)? "quit();\n" :
          "OS.Process.exit 0 : unit;\n");
$ml->soft_close();
exit 0;

sub render_output {
    my($chunk) = @_;
    foreach my $line (split '\n', protect_texi($chunk)) {
        print " \@print{} \@i{$line}\n";
    }
}

sub protect_texi {
    my($text) = @_;
    $text =~ s/\@/\@\@/g;
    $text =~ s/\{/\@\{/g;
    $text =~ s/\}/\@\}/g;
    ## This has nothing to do with texinfo,
    ## but we need to remove lines "erased" by \r
    $text =~ s/[^\r\n]*\r//g;
    return $text;
}
