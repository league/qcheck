VERSION=0.7
SML=sml
default: 
.PHONY: tests doc tar

tests:
	$(SML) -m tests/tests.cm </dev/null

doc: README.html

%.html: % makefile
	tail +2 $< | txt2html -8 +l | recode -d utf8..h3 >$@
	tidy -asxml -q -m $@

tar: reallyclean
	cd .. && rm -rf qcheck-$(VERSION) \
	      && cp -r qcheck qcheck-$(VERSION) \
	      && tar cvzf qcheck-$(VERSION).tgz qcheck-$(VERSION)

clean:
	-rm -f *~ */*~ */*/*~

reallyclean: clean
	-rm -rf .cm */.cm

