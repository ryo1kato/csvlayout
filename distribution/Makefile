all: csvlayout

csvlayout: csvlayout.rb texlayout.rb
	echo '#!/usr/bin/ruby -w' > $@
	cat texlayout.rb         >> $@
	egrep -v 'load "texlayout.rb"' csvlayout.rb >> $@
	chmod +x $@

install: csvlayout
	sudo install -m 755 -g root csvlayout /usr/local/bin

clean:
	rm -f csvlayout

.DELETE_ON_ERROR: csvlayout
.PHONY: all install clean
