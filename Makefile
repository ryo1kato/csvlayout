progname     =csvlayout
#version = $(shell grep 'Version=' programs/csvlayout.rb | sed -e 's/Version=//')
version      =  1.0.3


packagename  =  $(progname)-$(version)



package: prepare
	cp -r distribution $(packagename)
	make -C $(packagename) clean
	tar zcf $(packagename).tar.gz $(packagename)
	rm -rf $(packagename)


prepare: distribution/csvlayout.rb distribution/texlayout.rb distribution/csv-parse.rb-patch copy-samples

distribution/csvlayout.rb: programs/csvlayout.rb
	cp $^ $@

distribution/texlayout.rb: programs/texlayout.rb
	cp $^ $@

distribution/README: README
	cp $^ $@

distribution/README.ja: README.ja
	cp $^ $@

distribution/csv-parse.rb-patch:
	(cd distribution && \
	diff --context csv-1.0.0/lib/csv.rb ../programs/csv-parse.rb\
	>csv-parse.rb-patch ; true)

copy-samples: clean-sample
	cp -rf samples distribution

clean-sample:
	@set -e; for dir in samples/*; do make -C "$$dir" clean; done

clean: clean-sample
	rm -f distribution/csvlayout
	rm -f distribution/csvlayout.rb
	rm -f distribution/texlayout.rb
	rm -f distribution/csv-parse.rb-patch
	rm -f distribution/README*
	rm -rf distribution/samples
	rm -f csvlayout-*.tar.gz
