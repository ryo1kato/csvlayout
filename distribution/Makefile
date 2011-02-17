all: csvlayout

csvlayout: csvlayout.rb csv-parse.rb texlayout.rb
	echo '#!/usr/bin/ruby -w' > csvlayout
	cat texlayout.rb         >> csvlayout
	cat csv-parse.rb         >> csvlayout
	egrep -v 'load "texlayout.rb"|load "csv-parse.rb"' csvlayout.rb\
                                 >>csvlayout
	chmod +x csvlayout

csv-parse.rb: csv-parse.rb-patch csv-1.0.0/lib/csv.rb
	cp csv-1.0.0/lib/csv.rb ./csv-parse.rb
	patch csv-parse.rb csv-parse.rb-patch


install: csvlayout
	cp csvlayout /usr/local/bin

clean:
	rm -f csv-parse.rb
	rm -f csvlayout
