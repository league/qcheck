define each-ml
  for m in nj moscow mlton; do $(MAKE) -f Makefile.$$m $@; done
endef

default: 

all: docs
	$(each-ml)

test:
	$(each-ml)

FORMATS = info pdf
DOCS := LICENSE INSTALL $(addprefix doc/qcheck., $(FORMATS))
docs: $(DOCS)

DOCGEN = qcheck qcheck-ver sml-ver mosml qcheck-sig \
	 filesys-sig gen-sig prop-sig settings-sig
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
	$(RM) $(DOCGENS)
master.realclean: master.clean
	$(RM) src/qcheck-ver.sml 
	$(RM) $(DOCS) doc/qcheck.texi doc/qcheck-ver.texi

include Makefile.version
