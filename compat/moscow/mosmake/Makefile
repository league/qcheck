# $Id: Makefile,v 1.4 2002/11/18 23:58:17 makholm Exp $
#
# This makefile is *not* part of the Mosmake system itself; it merely
# controls how the author makes releases (and typesets documentation).
# Use at your own peril.
#
# Written by Henning Makholm in 2002.
# All copyright interest in this makefile is explicitly waived.
#
# This makefile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  You get it
# for free; don't bother me about it.

all: mosmake.info mosmake.dvi
VERSION = 0.9
clean:
	$(RM) mosmake.{cp,fn,ky,pg,tp,vr}{,s} mosmake.{aux,log,tmp,toc,txi0}
	$(RM) *~ mosmake-* filelist
realclean: clean
	$(RM) mosmake.{info*,dvi}
%.txi0: %.texi fixrefs.pl
	perl fixrefs.pl $< > $@
mosmake.dvi: mosmake.txi0
	$(TEXI2DVI) $<
#####################################################
DISTDIR = mosmake-$(VERSION)
dist: all
	$(MAKE) clean
	ln -s . $(DISTDIR)
	find $(DISTDIR)/ -type f | sort > filelist
	tar czf $(DISTDIR).tar.gz `grep -v $(DISTDIR)/CVS filelist`
	$(RM) filelist $(DISTDIR)

