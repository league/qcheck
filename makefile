define each-ml
  for m in nj moscow mlton poly; do $(MAKE) -f Makefile.$$m $@; done
endef

default: 

all: docs
	$(each-ml)

test:
	$(each-ml)

DOCS := README LICENSE INSTALL doc/qcheck.info doc/html/qcheck.html
EXTRAS := doc/qcheck.pdf   # don't include this with distribution
docs: $(DOCS)

DOCGEN = qcheck qcheck-ver sml-ver mosml QCHECK_SIG FILES_SIG \
         APPLICATIVE_RNG GEN_TYPES PREGEN_SIG PRETEXT_GENERATOR \
         INT_GENERATOR WORD_GENERATOR REAL_GENERATOR \
         DATE_TIME_GENERATOR PROPERTY_SIG SETTINGS_SIG

DOCGENS := $(addprefix doc/, $(addsuffix .texi, $(DOCGEN)))
$(DOCS): $(DOCGENS) doc/copying.texi doc/changes.texi

%.texi: %.texin scripts/transcribe.pl
	$(PERL) scripts/transcribe.pl $(SML) qcheck.cm <$< >$@

doc/%.texi: src/%.sml scripts/extract.pl
	$(PERL) scripts/extract.pl $< >$@

doc/mosml.texi:
	$(MAKE) -f Makefile.moscow $@

GETNODE=$(EMACS) --batch --no-site-file -l scripts/get-node.el --eval
LICENSE: doc/qcheck.info
	$(GETNODE) '(get-node "./$<" "License" "../$@")'
INSTALL: doc/qcheck.info
	$(GETNODE) '(get-node "./$<" "Installation" "../$@")'
README: doc/qcheck.info
	$(GETNODE) '(get-node "./$<" "Overview" "../$@")'

%.pdf: %.texi
	$(TEXI2DVI) -p -o $@ $<

doc/html:
	mkdir $@

doc/html/qcheck.html: doc/html
	cd $< && $(TEXI2HTML) -I ../.. -o . --css-include=../style.css ../qcheck.texi
	sed -i 's/-&gt;/\&rarr;/g' $</*.html
	sed -i 's/\-|/\&rsaquo;/g' $</*.html

## predist is 'chmod +x compat/moscow/mosmake/wrap; make docs clean'
dist:
	REPODIR=$$PWD darcs dist --dist-name qcheck-$(VERSION)

DIST_BRANCH = trunk
DIST_REPO = comsci.liu.edu:public_html/dist/qcheck

darcs-put:
	darcs put -v --no-pristine-tree $(DIST_REPO)/$(DIST_BRANCH)

darcs-push:
	darcs push $(DIST_REPO)/$(DIST_BRANCH)

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
	$(RM) $(VERSION_SRC)
	$(RM) $(DOCS) doc/qcheck.texi doc/qcheck-ver.texi
	$(RM) -r doc/html

include Makefile.version
