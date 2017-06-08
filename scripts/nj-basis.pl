#! /usr/bin/perl
use strict;

my $sml = $ARGV[0] || 'sml';

# We're relying on CM.make returning a boolean to see whether certain
# structures exist in the basis library. Previously I relied on the
# `use` function throwing an exception, but something about that
# changed in smlnj 110.80.

open(ML, '>detect.cm') or die 'cannot write detect.cm';
print ML "Group is\n\$/basis.cm\ndetect.sml\n";
close(ML);

open(ML, '>detect2.sml') or die 'cannot write detect2.sml';
print ML "open OS.Process;\n";
print ML "exit(if CM.make \"detect.cm\" then success else failure);\n";
close(ML);

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

unlink('detect.sml');
unlink('detect.cm');
unlink('detect2.sml');

exit;

sub check_structure
{
    my($s) = @_;
    system("rm -rf .cm");
    # ^^^ This sucks, but I swear if I don't clear out CM's cache
    # I get different results each time...
    open(ML, '>detect.sml') or die 'cannot write detect.sml';
    print ML "structure S = $s\n";
    close(ML);
    my $r = system("$sml detect2.sml </dev/null >/dev/null");
    if( !$r )
    {
        print "$s\n";
    }
}
