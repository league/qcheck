#! /usr/bin/perl
# $Id: cooker.pl,v 1.1 2002/11/16 21:08:13 makholm Exp $
#
# This is the main part of the Mosmake system. It reads Dependencies
# files from each of the directories named on the command line, and produces
# a Makefile fragment that correspond to them.
#
# Copyright (c) 2002 Henning Makholm
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

%cleandir = ();

$complained = 0 ;
sub complain {
    print STDERR @_, "\n" ;
    $complained++ ;
}
    
#############################################################################
#
# Read all of the relevant input files, and do preliminary processing
#
    
sub readfile_foldwhite {
    my $fn = shift ;
    my @result = () ;
    open DEPFILE, "<", $fn
        or complain "$fn:0: Cannot open this file" and return ;
    undef my $sofar ;
    while( <DEPFILE> ) {
        while( s/\s<([a-z, ]+):(([^<>\n]|<<|>>)*)>($|\s)/ <> /i ) {
            my $when = uc $1 ;
            my $tmp = $2 ;
            $tmp =~ s/<</</g ;
            $tmp =~ s/>>/>/g ;
            $tmp =~ s!([<>{}/\# _])!"_".($1 ^ "\x10")!ge ;
	    $tmp = join " ", map { "\n$_$tmp" } (split /[, ]*/,$when) ;
            s/ <> / $tmp / ;
        }
        s/\s*(\#.*)?$//s;
        s/\n/\#/g ;
        if( /([<>])/ ) {
            complain "$fn:$.: Unmatched '$1'" ;
        } elsif( /^\s/ ) {
            if( defined $sofar ) {
                $sofar .= $_ ;
            } else {
                complain "$fn:$.: Continuation line continues nothing" ;
            }
        } else {
            push @result, $sofar if defined $sofar ;
            if( /./ ) {
                $sofar = "$fn:$.: $_" ;
            } else {
                undef $sofar ;
            }
        }
    }
    push @result, $sofar if defined $sofar ;
    close DEPFILE ;
        
    for ( @result ) {
        s/\s+/ /g ;
    }
    return @result ;
}

sub readdepfile {
    my $fn = shift ;
    my $dir = $fn ;
    $dir =~ s:/+[^/]*$:/: or $dir = "./" ;
    $cleandir{$dir} = 1 ;
    my @lines = readfile_foldwhite $fn ;
    for( @lines ) {
        $pos = s/^(\S+:\d+: )/ / ? $1 : "" ;
        # Interpolate directory name
        s! ([^\#+\$%/=:])! $dir$1!g;
        # Remove leading slashes
        s! /! !g;
        # Resolve directory indirections
        while( s!(^|/| )([^/ ]+/\.\.|\.)/!$1! ) {}
        s!/($| )!/.$1!g ;
        # Do brace unfolding
        while( s/(\S*)\{([^{} ]*)\}(\S*)/\#\#/ ) {
            my ($a,$b,$c) = ($1,$2,$3) ;
            my @b = split /,/,$b ;
            complain $pos,"No comma between the braces in ${a}{$b}${c}"
                unless @b > 1 ;
            $abcs = $a . join("$c $a", @b) . $c ;
            s!\#\#!$abcs! ;
        }
        complain $pos,"Unmatched brace in $1" if /(\S*[{}]\S*)/ ;
        # Put the position back in front
        s/^ /$pos/ ;
    }
    return @lines ;
}

@alldefns = () ;
for $dir ( @ARGV ) {
    if( $dir =~ /^-/ ) {
        complain "No `$dir' option" ;
    } elsif( $dir =~ /[\s:=%\#\$]/ ) {
        complain "Strange characters in argument `$dir'" ;
    } else {
        push @alldefns, readdepfile $dir ;
    }
}

#############################################################################
#
# Intern all of the module definitions
#

%lineref = () ;
%worddef = () ;
for ( @alldefns ) {
    if( /^(\S+:\d+: )([^\s:=]+) ?(=|:) ?(.*)$/ ) {
        my ($pos,$defthis,$deftype,$defas) = ($1,$2,$3,$4) ;
        complain $pos,"Forbidden character $1 in name of defined module"
            if $defthis =~ /([%\#])/ ;
        if( exists $lineref{$defthis} ) {
            complain $pos,"Double definition of $defthis" ;
            complain $lineref{$defthis},"(Already defined here)" ;
        }
        $lineref{$defthis} = $pos ;
        $ismacro{$defthis} = $deftype eq "=" ;
        $worddef{$defthis} = " $defas " ;
    } elsif( /^(\S+:\d+: )/ ) {
        complain $1,"Unparseable definition block: [$_]" ;
    } else {
        die "Something has gone completely wrong: [$_]" ;
    }
}
if( exists $lineref{'+'} ) {
    complain $lineref{'+'},"The name `+' is magical. Do not define";
}

@alldefns = sort keys %lineref ;
exit 2 if $complained ;

#############################################################################
#
# Check that all depended-on modules are also defined somewhere
#

for $target ( @alldefns ) {
    $needplus = $ismacro{$target} ? 0 : 1 ;
    $pos = $lineref{$target} ;
    for( split ' ',$worddef{$target} ) {
        if( /^\+$/ ) {
            complain $pos,"Too many `+' separators" unless $needplus-- ;
        } elsif( /^$/ ) {
            # The leading space. Ignore.
        } elsif( /^\$\(\w+\)/ ) {
            # Imported module. Just trust it.
        } elsif( /^\#/ ) {
            # Extra compilation flags. Ignore.
        } elsif( /^%(\w+)$/ ) {
	    complain $pos,"Macros cannot contain flags like $_"
		if $ismacro{$target} ;
        } else {
            complain $pos,"Unknown dependency $_"
                unless exists $lineref{$_} ;
        }
    }
    $worddef{$target} .= "+ " if $needplus == 1 ;
}

#############################################################################
#
# Find out which directories to clean
#

foreach $module (@alldefns) {
    $_ = $module ;
    next if $ismacro{$_} ;
    s/[^\/]*$// ;
    $cleandir{$_} = 1 ;
}
@autoclean = map { "$_\{*.ui,*.uo,*~\}" } (keys %cleandir);
%cleandir = ();

#############################################################################
#
# OK. Now emit the fragment boilerplate
#

print <<'END_OF_BOILERPLATE';
# This is an AUTOMATICALLY GENERATED Makefile fragment
#
#
#        DO NOT EDIT THIS FILE!!
#
#
END_OF_BOILERPLATE

#############################################################################
#
# Handle %MOSMLYAC and %MOSMLLEX autogeneration specification

foreach $module ( @alldefns ) {
    next if $ismacro{$module} ;
    if( $worddef{$module} =~ s/ (%MOSMLLEX )+/ / ) {
	print "$module.sml: $module.lex\n" ;
	$worddef{$module} .= "%STRUCTURE %NODASHSIG " ;
	push @autoclean, "$module.sml" ;
    } elsif( $worddef{$module} =~ s/ (%MOSMLYAC )+/ / ) {
	print "$module.sml $module.sig: $module.grm\n" ;
	$worddef{$module} = "%STRUCTURE %DOTSIG %NODASHSIG #C-liberal " .
	    $worddef{$module} ;
	push @autoclean, "$module.sml", "$module.sig" ;
    }
}
    
#############################################################################
#
# Add automatic dependencies for foo-sig files if they exist

@alldefns = map {
    if( !$ismacro{$_} &&
	$worddef{$_} !~ s/ %NODASHSIG / / &&
        ( $worddef{$_} =~ s/ %DASHSIG / / ||
	  ( /^[^\#%\$]/ && -f "$_-sig.sml" ) ) ) {
        $m2 = "$_-sig" ;
        $worddef{$m2} = $worddef{$_} ;
        $worddef{$_} =~ s/ \+ / $m2 + / ;
        $worddef{$m2} =~ s/ \+ .*$/ + / ;
        $worddef{$m2} =~ s/ (%DOTSIG )+/ /g ;
	$worddef{$m2} .= "%NODOTSIG " ;
        $lineref{$m2} = $lineref{$_} ;
        ($m2,$_) ;
    } else {
        ($_) ;
    }
} @alldefns ;

#############################################################################
#
# Here is a subroutine to recursively expand a set of dependencies either
# with or without recursing through non-macros
#
%circularWarned = () ;
sub unfold {
    my $forLinking = shift ;
    my @stack = @_ ;
    my @collect = () ;
    my %unfolded = ("" => undef) ;
    my $curParent = "" ;
  unfoldloop:
    while( @stack ) {
        $_ = shift @stack ;
        if( s/^\#\#// ) {
            # Finished recursively unfolding something
            $curParent = $unfolded{$_} ;
            push @collect, $_ unless $ismacro{$_} ;
            # Mark it as visited by setting its hash entry to
            # existing but undefined (isn't the arcane semantics
            # of perl data structures fun to work with?)
            undef $unfolded{$_} ;
        } elsif( exists $unfolded{$_} ) {
            # We've already met this. Ignore.
            if( defined $unfolded{$_} ) {
                # Oops - we're not done with unfolding it yet
                my @cycle = ($_) ;
                for( my $m = $curParent; $m ne $_; $m=$unfolded{$m} ) {
                    next unfoldloop if $circularWarned{$m} ;
                    unshift @cycle, $m ;
                }
                complain $lineref{$_}, "Circular dependency: $_ depends on" ;
                foreach $m (@cycle) {
                    $circularWarned{$m} = 1 ;
                    complain $lineref{$m}, $m
                        , $m eq $_ ? " itself" : " which depends on" ;
                }
            }
        } elsif( $forLinking && $worddef{$_} || $ismacro{$_} ) {
            $unfolded{$_} = $curParent ;
            unshift @stack, split(' ',$worddef{$_}), "##$_" ;
            $curParent = $_ ;
        } else {
            undef $unfolded{$_} ;
            s/_(.)/$1 ^ "\x10"/ge if /^\#/ ;
            push @collect, $_ ;
        }
    }
    return @collect ;
}
#############################################################################
#
# Here is a subroutine to re-express a list of filenames such that they are
# valid when seen from the directory where the file given as first argument
# reside.
#
sub relativize {
    my @cd0 = split '/',shift ;
    pop @cd0 ; # ignore the filename component
    my @output = () ;
    foreach( @_ ) {
        if( /^[-:;\+%\/\$]/ ) {
            push @output, $_ ;
            next ;
        }
        my @target = split '/' ;
        my @cd = @cd0 ;
        while( @target && @cd && @target[0] eq @cd[0] ) {
            shift @target ;
            shift @cd ;
        }
        while( @cd ) {
            shift @cd ;
            unshift @target, ".." ;
        }
        push @output, join("/",@target) ;
    }
    return @output ;
}

#############################################################################
#
# OK. Now emit the standard rules
#

@makeall = ();
%binary = ();

$MOSMAKElen = length $ENV{MOSMAKE} || 8 ;

sub printmany {
    my $anyyet = 0 ;
    my $left = 76 ;
    my $iscommand = $_[0] =~ /^\t/ ;
    $printmanytarget = $1 if $_[0] =~ /(.*):$/ ;
    while( @_ ) {
	$word = shift ;
	print "\t" if $word =~ s/^\t// ;
	next unless $word ;
        $len = length $word ;
        if( $iscommand ) {
            if( $word =~ /^\$\(MOSMLC\./ ) {
                $len = $MOSMAKElen + 6 + length $printmanytarget ;
            } elsif( $word eq '$(RM)' ) {
                $len = 5 ; # rm -f
            } elsif( $word =~ /^\$\(/ ) {
                $len = 80 ; # we don't know how long, but it's probably long
            }
        }
	if( $len > $left && $anyyet ) {
	    print "\\\n   " ;
	    $left = 73 ;
	}
	$left -= $len + 1 ;
	print "$word " ;
        $anyyet = 1 ;
    }
    print "\n" ;
}

sub moscommand {
    my $target = shift ;
    my ($rtarget) = relativize $target, $target ;
    printmany "$target:", sort (map {/^\#/ ? () : ($_)} @_) ;
    printmany ("\t\$(MOSMLC.wrap:\@\@=$rtarget)",$comptype,"-c",
                relativize $target, (map {s/^\#//; $_} @_) ) ;
}

sub moscommand2 {
    my $basename = shift ;
    my ($nondir) = relativize $basename, $basename ;
    printmany "$basename.ui $basename.uo:", sort (map {/^\#/ ? () : ($_)} @_) ;
    print "$basename.ui $basename.uo: MOSMLC.both = \\\n" ;
    print "  \$(MOSMLC.wrap:\@\@='$nondir.ui $nondir.uo') $comptype -c \\\n" ;
    printmany " ",relativize $basename, (map {s/^\#//; $_} @_) ;
}  

foreach $module (@alldefns) {
    next if $ismacro{$module} ;
    
    @o_depends = ();
    @i_depends = ();
    %seen = () ;
    @alldeps = unfold 0, split ' ',$worddef{$module} ;
    foreach( @alldeps ) {
        if( /^\+$/ ) {
            @i_depends = @o_depends ;
        } elsif( /^%/ ) {
            $seen{$_} = 1 ;
        } elsif ( s/^\#(\w)// ) {
            push @o_depends,"#$_" if $1 eq "C";
        } else {
            push @o_depends,"$_.ui" ;
        }
    }

    if( $seen{"%NOCOMPILE"} ) {
        delete $seen{"%NOCOMPILE"} ;
    } else {
        if( $seen{"%NODOTSIG"} ) {
	    delete $seen{"%NODOTSIG"} ;
	    $dotsig = 0 ;
	} elsif( $seen{"%DOTSIG"} ) {
	    delete $seen{"%DOTSIG"} ;
	    $dotsig = 1 ;
        } else {
            $dotsig = -f "$module.sig" ;
        }
        
        if( $seen{"%STRUCTURE"} ) {
            delete $seen{"%STRUCTURE"};
            $comptype = "-structure";
        } else {
            $comptype = "-toplevel";
        }
        
        if( $dotsig ) {
            moscommand("$module.ui",@i_depends,"$module.sig");
            print "$module.uo: $module.ui\n";
            moscommand("$module.uo",@o_depends,"$module.sml");
        } else {
            moscommand2($module,@o_depends,"$module.sml") ;
        }
    }

    if( $seen{"%PROGRAM"} ) {
        delete $seen{"%PROGRAM"};
        delete $seen{"%OPTIONAL"};
        my $binary = $module ;
        $binary =~ s!.*/!! ;
        if( defined $binary{$binary} ) {
            complain $lineref{$module},"Already one program called $binary";
            complain $lineref{$binary{$binary}},"(here). Ignoring the former";
        } else {
            $binary{$binary} = $module ;
        }
    }

    for( keys %seen ) {
        complain $lineref{$module},"Unrecognized/unused flag $_" ;
    }
}

for (sort keys %binary) {
    my $module = $binary{$_} ;
    my $binary = $_ . '$(EXEEXT)' ;
    @commandline = () ;
    @dependencies = () ;
    $makedefault = 1 ;
    foreach( unfold 1, $module ) {
        if( /^%OPTIONAL$/ )  {
            $makedefault = 0 ;
        } elsif( /^(\+$|%)/ ) {
            # ignore
        } elsif( s/^\#(\w)// ) {
            push @commandline, $_ if $1 eq "L" ;
        } else {
            push @commandline, "$_.uo" ;
            push @dependencies, "$_.uo" ;
        }
    }
    printmany "$binary:", @dependencies ;
    printmany "\t\$(MOSMLC.link:\@\@=\$\@)",@commandline,"-o $binary" ;
#   print "$binary,smartmade: $binary\n" ;
    push @makeall, "$binary,smartmade" if $makedefault ;
}    

printmany "all:", sort @makeall if @makeall ;
printmany "mosmake.mostlyclean:" ;
printmany "\t\$(RM)", sort @autoclean ;
printmany "mosmake.clean:" ;
printmany "\t\$(RM)", map {"$_\$(EXEEXT)"} (sort (keys %binary))
    unless %binary == 0 ;
