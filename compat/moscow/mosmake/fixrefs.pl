#! /usr/bin/perl
# $Id: fixrefs.pl,v 1.2 2002/11/18 23:58:17 makholm Exp $
#
# This small script was written to help author the Mosmake manual.
# It replaces "@xref{nodename}" in the texinfo source with
# "@xref{nodename,,Section Heading}" such that cross-references
# in the typeset manual will come out right.
#
# Written by Henning Makholm in 2002.
# All copyright interest in this program is explicitly waived.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  You get it
# for free; don't bother me about it.

@texi = <> ;
for( @texi ) {
    if( /^\@node ([^,]*)/ ) {
        my $tmp = $1 ;
        print STDERR "No section heading for `$sawnode'\n"
            if $sawnode && $sawnode ne "Top" ;
        $sawnode = $tmp ;
    } elsif( /^\@((sub)*section|chapter|unnumbered) (.*)/ ) {
        $title = $3 ;
        $title =~ s/,/{,}/ ;
        $titles{$sawnode} = $title if $sawnode ;
        $sawnode = 0 ;
    } elsif( /\@anchor\{([^,\}]+)\}/ ) {
        $titles{$1} = $title ;
    }
}
$titles{$sawnode} = $title if $sawnode ;

for( @texi ) {
    while( s/(\@p?x?ref)\{([^,\}]+)\}/\@ref:/ ) {
        $cmd = $1 ;
        $target = $2 ;
        if( $titles{$target} ) {
            $target = "$target,,$titles{$target}" ;
        } else {
            print STDERR "Unknown target `$target'" ;
        }
        s/\@ref:/$cmd\{$target\}/ ;
    }
}

print @texi ;

        
