define each-ml
  for m in nj moscow mlton; do $(MAKE) -f Makefile.$$m $@; done
endef

DOCS:=$(addprefix doc/qcheck., info pdf)

default: 
all: docs
	$(each-ml)
test:
	$(each-ml)
docs: $(DOCS)

$(DOCS): doc/qcheck-ver.texi doc/qcheck.texi

%.texi: %.texin doc/transcribe.pl
	$(PERL) doc/transcribe.pl $(SML) $< >$@

%.pdf: %.texi
	$(TEXI2DVI) -p -o $@ $<

%.html: % Makefile
	tail +2 $< | txt2html -8 +l | recode -d utf8..h3 >$@
	tidy -asxml -q -m $@

tar: clean
	cd .. && rm -rf qcheck-$(VERSION) \
	      && cp -r qcheck qcheck-$(VERSION) \
	      && tar cvzf qcheck-$(VERSION).tgz \
	           --exclude=.svn qcheck-$(VERSION)

mostlyclean: master.mostlyclean
	$(each-ml)
clean: master.clean
	$(each-ml)
realclean: master.realclean
	$(each-ml)

master.mostlyclean:
	$(RM) compat/*/*~ tests/data/*~ doc/*~ *~
master.clean: master.mostlyclean
master.realclean: master.clean
	$(RM) src/qcheck-ver.sml 
	$(RM) $(DOCS) doc/qcheck.texi doc/qcheck-ver.texi

include Makefile.version
