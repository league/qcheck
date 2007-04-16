#! /usr/bin/perl
use strict;

my $sml = $ARGV[0] || 'sml';

check_structure('FixedInt');
check_structure('Int');
check_structure('Int4');
check_structure('Int8');
check_structure('Int16');
check_structure('Int24');
check_structure('Int31');
check_structure('Int32');
check_structure('Int48');
check_structure('Int63');
check_structure('Int64');
check_structure('IntInf');
check_structure('LargeInt');
check_structure('Position');

check_structure('LargeReal');
check_structure('Real');
check_structure('Real32');
check_structure('Real64');

check_structure('LargeWord');
check_structure('SysWord');
check_structure('Word');
check_structure('Word4');
check_structure('Word8');
check_structure('Word16');
check_structure('Word24');
check_structure('Word31');
check_structure('Word32');
check_structure('Word48');
check_structure('Word63');
check_structure('Word64');
check_structure('WordInf');

check_structure('WideText');
unlink('test.sml');
exit;

sub check_structure 
{
    my($s) = @_;
    open(ML, '>test.sml') or die 'cannot write test.sml';
    print ML "TextIO.closeOut TextIO.stdErr;\n";
    print ML "structure S = $s\n";
    close(ML);
    my $r = system("$sml test.sml </dev/null >/dev/null");
    if( !$r )
    {
        print "$s\n";
    }
}

