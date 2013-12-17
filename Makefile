progname     = csvlayout
version      = 1.0.3
packagename  = $(progname)-$(version)


package: prepare
	cp -r distribution $(packagename)
	make -C $(packagename) clean
	@printf "Test build for samples/* ... "
	@set -e; for dir in $(packagename)/samples/*; do make -C "$$dir"; done > /dev/null
	@set -e; for dir in $(packagename)/samples/*; do make -C "$$dir" clean; done > /dev/null
	@printf "OK\n"
	tar zcf $(packagename).tar.gz $(packagename)
	rm -rf $(packagename)


prepare: distribution/csvlayout.rb distribution/texlayout.rb copy-samples
	make -C distribution
	ln -sfn distribution/csvlayout .
	@printf "Test build for samples/* ... "
	@set -e; for dir in samples/*; do make -C "$$dir"; done > /dev/null
	@printf "OK\n"

distribution/csvlayout.rb: programs/csvlayout.rb
	cp $^ $@

distribution/texlayout.rb: programs/texlayout.rb
	cp $^ $@

distribution/README: README
	cp $^ $@

distribution/README.ja: README.ja
	cp $^ $@

copy-samples: clean-sample
	cp -rf samples distribution

clean-sample:
	@set -e; for dir in samples/*; do make -C "$$dir" clean; done

clean: clean-sample
	rm -f csvlayout
	rm -f distribution/csvlayout
	rm -f distribution/csvlayout.rb
	rm -f distribution/texlayout.rb
	rm -f distribution/README*
	rm -rf distribution/samples
	rm -f csvlayout-*.tar.gz
