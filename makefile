define each-ml
  for m in nj moscow mlton; do $(MAKE) -f Makefile.$$m $@; done
endef

default: 

all: docs
	$(each-ml)

test:
	$(each-ml)

DOCS := LICENSE INSTALL doc/qcheck.info doc/html/qcheck.html
EXTRAS := doc/qcheck.pdf   # don't include this with distribution
docs: $(DOCS)

DOCGEN = qcheck qcheck-ver sml-ver mosml qcheck-sig \
	 file-sys-sig gen-sig prop-sig settings-sig
DOCGENS := $(addprefix doc/, $(addsuffix .texi, $(DOCGEN)))
$(DOCS): $(DOCGENS) doc/copying.texi

%.texi: %.texin doc/transcribe.pl
	$(PERL) doc/transcribe.pl $(SML) qcheck.cm <$< >$@

doc/%.texi: src/%.sml doc/extract.pl
	$(PERL) doc/extract.pl $< >$@

doc/mosml.texi:
	$(MAKE) -f Makefile.moscow $@

GETNODE=$(EMACS) --batch --no-site-file -l doc/get-node.el --eval
LICENSE: doc/qcheck.info
	$(GETNODE) '(get-node "./$<" "License" "../$@")'
INSTALL: doc/qcheck.info
	$(GETNODE) '(get-node "./$<" "Installation" "../$@")'

%.pdf: %.texi
	$(TEXI2DVI) -p -o $@ $<

doc/html:
	mkdir $@

doc/html/qcheck.html: doc/html
	cd $< && $(TEXI2HTML) -I ../.. ../qcheck.texi

## Reminder: to build a package, we need to
##    make all test tar
## in that order
tar: clean
	cd .. && rm -rf qcheck-$(VERSION) \
	      && cp -r qcheck qcheck-$(VERSION) \
	      && tar cvzf qcheck-$(VERSION).tgz \
	           --exclude=.svn qcheck-$(VERSION)

dist:
	darcs dist -d qcheck-$(VERSION)

mostlyclean: master.mostlyclean
	$(each-ml)
clean: master.clean
	$(each-ml)
realclean: master.realclean
	$(each-ml)

master.mostlyclean:
	$(RM) compat/*/*~ tests/data/*~ doc/*~ *~
master.clean: master.mostlyclean
	$(RM) $(DOCGENS) $(EXTRAS)
master.realclean: master.clean
	$(RM) src/qcheck-ver.sml 
	$(RM) $(DOCS) doc/qcheck.texi doc/qcheck-ver.texi
	$(RM) -r doc/html

include Makefile.version
