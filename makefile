
define each-ml
  for m in nj moscow mlton; do $(MAKE) -f Makefile.$$m $@; done
endef

default: 
all:
	$(each-ml)
test:
	$(each-ml)

doc: README.html

%.html: % Makefile
	tail +2 $< | txt2html -8 +l | recode -d utf8..h3 >$@
	tidy -asxml -q -m $@

tar: realclean
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

include Makefile.version
