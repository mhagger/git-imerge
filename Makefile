
BIN=git-imerge
PREFIX=/usr/local

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

install: $(BIN)
        install $(BIN) $(PREFIX)/bin

uninstall:
        rm $(PREFIX)/bin/$(BIN)
