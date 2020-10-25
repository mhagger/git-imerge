all: html

html: talk.html

talk.html: talk.rst
	rst2s5 --theme=small-white --current-slide $< $@

clean:
	rm -f talk.html
