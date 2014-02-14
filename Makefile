prefix = $(HOME)
bindir = $(prefix)/bin

INSTALL = install

RST := \
    README.rst \
    TODO.rst

all:

html: $(RST:.rst=.html)

%.html: %.rst
	rst2html $< >$@


module := doc/presentations/GitMerge-2013

html: $(module)/talk.html

$(module)/talk.html: $(module)/talk.rst
	rst2s5 --theme=small-white --current-slide $< $@

install: all
	$(INSTALL) -d -m 755 '$(bindir)'
	$(INSTALL) -m 755 git-imerge '$(bindir)'
