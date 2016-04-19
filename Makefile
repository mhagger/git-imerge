
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
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	install $(BIN) $(DESTDIR)$(PREFIX)/bin
	@mkdir -p $(DESTDIR)/etc/bash_completion.d
	cp -f git-imerge.bashcomplete $(DESTDIR)/etc/bash_completion.d/git-imerge

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/$(BIN)
	rm -f $(DESTDIR)/etc/bash_completion.d/git-imerge
