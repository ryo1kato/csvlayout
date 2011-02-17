filename ?= vcard

csvlayout = ../../distribution/csvlayout

ptex      = platex-euc
xdvi      = xdvi-ja
dvi2pdf   = dvipdfmx
acroread  = open  #for MacOSX
#acroread  = acroread #for Linux

all: $(filename).dvi

$(csvlayout):
	make -C ../..
	make -C ../../distribution


$(filename).dvi: $(filename).tex
	$(ptex) $(filename).tex

$(filename).pdf: $(filename).dvi
	$(dvi2pdf) $<

$(filename).tex: $(filename).fmt $(filename).csv $(csvlayout)
	$(csvlayout) $^ > $@ || (rm $@; false)


dvi: $(filename).dvi
	$(xdvi) $^ &

ps: $(filename).dvi
	dvi2ps $^ > $@

pdf: $(filename).pdf
	$(acroread) $^


clean:
	rm -f $(foreach ext,tex aux log dvi ps pdf,$(filename).$(ext))

