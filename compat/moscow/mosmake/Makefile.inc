# $Id: Makefile.inc,v 1.2 2002/11/18 23:58:17 makholm Exp $ -*- Makefile -*-
#
# This is the boilerplate Makefile fragment for the Mosmake system.
# Include it from your main Makefile after having set $(MOSMAKE) to
# point to this directory.
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

.PHONY: all realclean mosmake.clean clean mosmake.clean \
        mostlyclean mosmake.mostlyclean depend ajour .FORCE
all:

# The $(MOSMAKE)/dos script as well as $(MOSMAKE)/cooker.pl both want to
# know the value of MOSMAKE, so export it
export MOSMAKE

##############################################################
#   Generic rule for lexers. 
#
%.sml:: %.lex
	$(MOSMAKE)/wrap . $(MOSMAKE.@@:@@=$@) $(MOSMLLEX) $<

###############################################################
#   Generic rules for parsers.
#
%.sig %.sml:: %.grm
	$(MOSMAKE)/wrap . $(MOSMAKE.@@:@@='$*.sig $*.sml') $(MOSMLYAC) $<

##############################################################
#   Generic rule for running mosmlc to get two outputs
#
# MOSMLC.both will be overridden in target-dependent assignments
#
%.ui %.uo: %.sml
	@[ ! -f $*.sig ] || \
	(echo $*.sig:1: This file is new - please make depend ; exit 1 )
	$(MOSMLC.both)
MOSMLC.both = $(MOSMLC.wrap:@@=.) $(notdir $<)

############################################################
#   Cleaning rules

mostlyclean: mosmake.mostlyclean
clean: mosmake.clean
realclean: mosmake.realclean
mosmake.realclean: mosmake.clean
	$(RM) mosmake.dep
mosmake.clean: mosmake.mostlyclean

############################################################
#    Rules for automatic makefile maintenance

ifndef MOSMAKEDIRS
MOSMAKEDIRS = .
endif
ifndef MOSMAKEDEPS
MOSMAKEDEPS = Dependencies
endif
MOSMAKE.in := $(patsubst %,%/$(MOSMAKEDEPS),$(MOSMAKEDIRS))

ajour: mosmake.dep
depend:
	$(PERL) $(MOSMAKE)/cooker.pl $(MOSMAKE.in) > mosmake.dep
mosmake.dep: $(MOSMAKE)/cooker.pl $(MOSMAKE.in)
	$(PERL) $(MOSMAKE)/cooker.pl $(MOSMAKE.in) > $@

############################################################
#    Variables used the the generated rules

MOSMLC.wrap = $(MOSMAKE)/wrap $(dir $@) $(MOSMAKE.@@) $(MOSMLC) $(MOSMLFLAGS)
MOSMLC.link = $(MOSMLC.wrap)
ifeq "$(EXEEXT)" ".exe"
    MOSMLC.link = $(MOSMLC.wrap:$(MOSMAKE)/wrap=$(MOSMAKE)/dos)
endif

# Try to figure out whether to use the smartmake logic (which tries to
# avoid recompiling too much if an .ui file is remade but is found not
# to have changed). MAKEFILE_LIST was added to GNU make in version 3.80
# which was also the version when -t began working correctly.
ifdef MAKEFILE_LIST
  SMARTMAKE = yes
else
  SMARTMAKE = no
endif
ifeq "$(SMARTMAKE)" "yes"
    # The $(MAKE) macro is magic when it appears in an *unexpanded*
    # command linje. $(MOSMAKE.smart) hides $(MAKE) in a layer of
    # indirection such that the command in the %,smartmade rule
    # will *not* be run when make is invoked with the -n or -t
    # flags.
    # However, that is too subtle to rely upon in the long run,
    # so let's also explicitly set $(MOSMAKE.smart) to the empty
    # string in the recursive invocation.
    MOSMAKE.smart = @$(MAKE) --no-print-directory MOSMAKE.smart= -t $<
    %,smartmade: MOSMAKE.@@ = @@
else
    MOSMAKE.smart =
endif
MOSMAKE.@@ = .
%,smartmade: % .FORCE
	$(MOSMAKE.smart)

############################################################
#    Include the files with the generated rules

-include mosmake.dep

