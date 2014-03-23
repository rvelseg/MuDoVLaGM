#################
# Description
#################
#
# This is a Makefile to administer diferents versions of a document
# (inspired in scientific pepers) based on a single .tex file. See
# README.md for some use intructions.

#################
# Known issues
#################
#
# if one of the standard or special version names are contained in
# another, i.e. `foo` and `Betterfoo`, then the `sed` command will not
# be able to isolate the former and the compilation will fail.
#
# footnotes listed in references fail when references are displayed as
# text.
#

#################
# TODO
#################
#
# TODO: study the possibility of use of CTAN packages with similar
# purposes: http://ctan.org/topic/cond-comp
# http://www.ctan.org/topic/compilation.  Particularly:
# http://ctan.org/pkg/renditions http://ctan.org/pkg/comment Check
# http://www.ctan.org/pkg/latex-make . One of the features of the
# present implementation that should not be lost if using one on these
# packages is the possibility for a block to apply to multiple
# versions.
#
# TODO: automate the generation of figure-list files, it could be with
# a python script.
#
# TODO: move this issues to the github bug tracking system.
#
# TODO: implement auto completion (TAB) over available
# versions. Caution, this could mess with the autocompletion of
# make. See
# http://stackoverflow.com/questions/516305/bash-completion-for-make-with-generic-targets-in-a-makefile
# It could be enabled with something like `make configure`.

#################
# Variables
#################

SPECIAL_VERSIONS := $(shell sed -n '1,/\\begin{document}/ s/.*\\MDbegin\*{\([^}]*\)}.*/\1/p' document.tex | awk '{ for (f = 1; f <= NF; f++) {print $$f } }' | sort | uniq)

SPECIAL_VERSIONS_PDF := $(addprefix document-, $(addsuffix .pdf, ${SPECIAL_VERSIONS}))

SPECIAL_VERSIONS_ZIP := $(addsuffix .zip, ${SPECIAL_VERSIONS})

STANDARD_VERSIONS := $(shell sed -n '1,/\\begin{document}/ s/.*\\MDbegin{\([^}]*\)}.*/\1/p' document.tex | awk '{ for (f = 1; f <= NF; f++) {print $$f } }' | sort | uniq)

STANDARD_VERSIONS := $(filter-out $(SPECIAL_VERSIONS), $(STANDARD_VERSIONS) )

STANDARD_VERSIONS_PDF := $(addprefix document-, $(addsuffix .pdf, ${STANDARD_VERSIONS}))


STANDARD_VERSIONS_TEX := $(addprefix document-, $(addsuffix .tex, ${STANDARD_VERSIONS}))

NOT_FOUND_VERSIONS := $(filter document-%.pdf,$(MAKECMDGOALS))
NOT_FOUND_VERSIONS := $(filter-out $(STANDARD_VERSIONS_PDF),$(NOT_FOUND_VERSIONS))
NOT_FOUND_VERSIONS := $(filter-out $(SPECIAL_VERSIONS_PDF),$(NOT_FOUND_VERSIONS))
ifneq "$(NOT_FOUND_VERSIONS)" ""	
$(error Error. Versions not found: ${NOT_FOUND_VERSIONS}. See 'make list')
endif

#################
# Targets
#################

# to make the default version:
document.pdf : document.tex references.bib
	pdflatex -interaction=batchmode document
	bibtex -terse document
	pdflatex -interaction=batchmode document
	pdflatex -interaction=batchmode document

# to make standard versions:
document-%.pdf : document.tex references.bib
	cp document.tex document-$*.tex
	 # comment the default parameters:
	sed -i '/%.*\\MDbegin\*\?{[^}]*}/,/%.*\\MDend\*\?{[^}]*}/ s/^ *[^%].*/% &/' document-$*.tex 
	 # uncomment the specific parameters:
	sed -i '/%.*\\MDbegin{[^}]*$*[^}]*}/,/%.*\\MDend{[^}]*$*[^}]*}/ s/% *//' document-$*.tex
	 # remove latex comments:
	 # sed -i -e 's/^%.\+//' -e 's/\([^\]\)%.\+/\1/' document-$*.tex
	./utils/removeLatexComments.pl document-$*.tex > tmpRLC.tex
	mv tmpRLC.tex document-$*.tex
	 # remove two or more blank lines:
	sed -i -r ':a; /^\s*$$/ {N;ba}; s/( *\n *){2,}/\n\n/' document-$*.tex
	 # compile multiple times
	pdflatex -interaction=batchmode document-$*
	bibtex -terse document-$*
	pdflatex -interaction=batchmode document-$*
	pdflatex -interaction=batchmode document-$*

# special versions 
document-arXiv.pdf : \
document.tex \
images/1.pdf \
images/2.pdf \
images/3.pdf \
images/4.pdf \
images/5.pdf \
images/6.pdf \
images/7.pdf \
images/8.pdf \
special_versions/arXiv/anc/ \
jasatex.cls \
my-private.sty \
references.bib ;
	 # check if tmp directory exist, and create it if necesary
	( [ -d tmpdir-arXiv/ ] && echo "tmp directory found" ) || mkdir -p tmpdir-arXiv/
	 # copy source files, images and ancillary files
	cp ./my-private.sty tmpdir-arXiv/
	cp -a ./special_versions/arXiv/anc tmpdir-arXiv/
	cp ./jasatex.cls tmpdir-arXiv/
	cp ./images/1.pdf tmpdir-arXiv/1.pdf
	cp ./images/2.pdf tmpdir-arXiv/2.pdf
	cp ./images/3.pdf tmpdir-arXiv/3.pdf
	cp ./images/4.pdf tmpdir-arXiv/4.pdf
	cp ./images/5.pdf tmpdir-arXiv/5.pdf
	cp ./images/6.pdf tmpdir-arXiv/6.pdf
	cp ./images/7.pdf tmpdir-arXiv/7.pdf
	cp ./images/8.pdf tmpdir-arXiv/8.pdf
	cp ./references.bib tmpdir-arXiv/references.bib
	cp ./document.tex tmpdir-arXiv/document-arXiv.tex
	 # comment the default parameters:
	sed -i '/%.*\\MDbegin\*\?{[^}]*}/,/%.*\\MDend\*\?{[^}]*}/ s/^ *[^%].*/% &/' tmpdir-arXiv/document-arXiv.tex 
	 # uncomment the specific parameters:
	sed -i '/%.*\\MDbegin\*\?{[^}]*arXiv[^}]*}/,/%.*\\MDend\*\?{[^}]*arXiv[^}]*}/ s/% *//' tmpdir-arXiv/document-arXiv.tex 
	 # remove latex comments:
	 #sed -i -e 's/^%.\+//' -e 's/\([^\]\)%.\+/\1/' tmpdir-arXiv/document-arXiv.tex
	./utils/removeLatexComments.pl tmpdir-arXiv/document-arXiv.tex > tmpdir-arXiv/tmp.tex
	mv tmpdir-arXiv/tmp.tex tmpdir-arXiv/document-arXiv.tex
	 # expand custom macros with their definitions
	cd tmpdir-arXiv && de-macro document-arXiv.tex
	cd tmpdir-arXiv && mv document-arXiv-clean.tex document-arXiv.tex
	rm tmpdir-arXiv/my-private.sty
	rm tmpdir-arXiv/document-arXiv
	 # change paths for images
	sed -i 's|\\includegraphics{images/\(.\+\).pdf}|\\includegraphics{\1.pdf}|' tmpdir-arXiv/document-arXiv.tex
	 # remove two or more blank lines:
	sed -i -r ':a; /^\s*$$/ {N;ba}; s/( *\n *){2,}/\n\n/' tmpdir-arXiv/document-arXiv.tex
	 # create the zip 
	cd tmpdir-arXiv && zip -r ../arXiv.zip ./*
	zip -d arXiv.zip references.bib
	 # compile multiple times:
	cd tmpdir-arXiv && pdflatex -interaction=batchmode document-arXiv
	cd tmpdir-arXiv && bibtex -terse document-arXiv
	cd tmpdir-arXiv && pdflatex -interaction=batchmode document-arXiv
	cd tmpdir-arXiv && pdflatex -interaction=batchmode document-arXiv
	 # append the bbl file to the zip file
	cd tmpdir-arXiv && zip -g ../arXiv.zip document-arXiv.bbl
	 # move the pdf to main directory
	mv tmpdir-arXiv/document-arXiv.pdf .

document-journalX.pdf : \
document.tex \
images/1.pdf \
images/2.pdf \
images/3.pdf \
images/4.pdf \
images/5.pdf \
images/6.pdf \
images/7.pdf \
images/8.pdf \
my-private.sty \
special_versions/journalX/journalX-figure-list.in \
references.bib ;
	 # check if tmp directory exist, and create it if necesary
	( [ -d tmpdir-journalX/ ] && echo "tmp directory found" ) || mkdir -p tmpdir-journalX/
	 # copy source files and images 
	cp ./my-private.sty tmpdir-journalX/
	cp ./images/1.pdf tmpdir-journalX/1.pdf
	cp ./images/2.pdf tmpdir-journalX/2.pdf
	cp ./images/3.pdf tmpdir-journalX/3.pdf
	cp ./images/4.pdf tmpdir-journalX/4.pdf
	cp ./images/5.pdf tmpdir-journalX/5.pdf
	cp ./images/6.pdf tmpdir-journalX/6.pdf
	cp ./images/7.pdf tmpdir-journalX/7.pdf
	cp ./images/8.pdf tmpdir-journalX/8.pdf
	cp ./references.bib tmpdir-journalX/references.bib
	cp ./document.tex tmpdir-journalX/document-journalX.tex
	 # change images format
	cd tmpdir-journalX && pdftops -eps 1.pdf
	cd tmpdir-journalX && pdftops -eps 2.pdf
	cd tmpdir-journalX && pdftops -eps 3.pdf
	cd tmpdir-journalX && pdftops -eps 4.pdf
	cd tmpdir-journalX && pdftops -eps 5.pdf
	cd tmpdir-journalX && pdftops -eps 6.pdf
	cd tmpdir-journalX && pdftops -eps 7.pdf
	cd tmpdir-journalX && pdftops -eps 8.pdf
	rm tmpdir-journalX/1.pdf
	rm tmpdir-journalX/2.pdf
	rm tmpdir-journalX/3.pdf
	rm tmpdir-journalX/4.pdf
	rm tmpdir-journalX/5.pdf
	rm tmpdir-journalX/6.pdf
	rm tmpdir-journalX/7.pdf
	rm tmpdir-journalX/8.pdf
	 # comment the default parameters:
	sed -i '/%.*\\MDbegin\*\?{[^}]*}/,/%.*\\MDend\*\?{[^}]*}/ s/^ *[^%].*/% &/' tmpdir-journalX/document-journalX.tex 
	 # uncomment the specific parameters:
	sed -i '/%.*\\MDbegin\*\?{[^}]*journalX[^}]*}/,/%.*\\MDend\*\?{[^}]*journalX[^}]*}/ s/% *//' tmpdir-journalX/document-journalX.tex 
	 # remove latex comments:
	 #sed -i -e 's/^%.\+//' -e 's/\([^\]\)%.\+/\1/' tmpdir-journalX/document-journalX.tex
	./utils/removeLatexComments.pl tmpdir-journalX/document-journalX.tex > tmpdir-journalX/tmp.tex
	mv tmpdir-journalX/tmp.tex tmpdir-journalX/document-journalX.tex
	 # expand custom macros with their definitions
	cd tmpdir-journalX && de-macro document-journalX.tex
	cd tmpdir-journalX && mv document-journalX-clean.tex document-journalX.tex
	rm tmpdir-journalX/my-private.sty
	rm tmpdir-journalX/document-journalX
	 # change paths for images
	sed -i 's|\\includegraphics{images/\(.\+\).pdf}|\\includegraphics{\1.eps}|' tmpdir-journalX/document-journalX.tex
	 # quick and dirty solution for section references
	sed -i -f special_versions/journalX/journalX-sections.sed tmpdir-journalX/document-journalX.tex
	 # embeed the list of figures
	sed -i '/\\bibliography{references}/ r special_versions/journalX/journalX-figure-list.in' tmpdir-journalX/document-journalX.tex
	 # remove two or more blank lines:
	 # an alternative: awk '!NF {if (++n <= 2) print; next}; {n=0;print}'
	sed -i -r ':a; /^\s*$$/ {N;ba}; s/( *\n *){2,}/\n\n/' tmpdir-journalX/document-journalX.tex
	 # create the zip 
	cd tmpdir-journalX && zip -r ../journalX.zip ./*
	zip -d journalX.zip references.bib
	zip -d journalX.zip document-journalX.tex
	 # compile multiple times:
	cd tmpdir-journalX && pdflatex -interaction=batchmode document-journalX
	cd tmpdir-journalX && bibtex -terse document-journalX
	cd tmpdir-journalX && pdflatex -interaction=batchmode document-journalX
	cd tmpdir-journalX && pdflatex -interaction=batchmode document-journalX
	 # embed bbl file
	sed -i 's/\\bibliographystyle{unsrtnat}//' tmpdir-journalX/document-journalX.tex
	sed -i '/\\bibliography{references}/ r tmpdir-journalX/document-journalX.bbl' tmpdir-journalX/document-journalX.tex
	sed -i 's/\\bibliography{references}//' tmpdir-journalX/document-journalX.tex
	 # inlcude the final version of the tex file in the zip file
	cd tmpdir-journalX && zip -g ../journalX.zip document-journalX.tex
	 # compile again
	cd tmpdir-journalX && pdflatex -interaction=batchmode document-journalX
	cd tmpdir-journalX && pdflatex -interaction=batchmode document-journalX
	 # move the pdf to main directory
	mv tmpdir-journalX/document-journalX.pdf .

document-all.tar.gz : all
	tar -czf document-all.tar.gz document.pdf $(STANDARD_VERSIONS_PDF) $(SPECIAL_VERSIONS_PDF) $(SPECIAL_VERSIONS_ZIP)

#################
# Phony targets
#################

.PHONY : clean list all wipe

list : 
	@echo "Standard versions: "
	@echo $(STANDARD_VERSIONS_PDF)
	@echo "Special versions: "
	@echo $(SPECIAL_VERSIONS_PDF)

all : document.pdf $(STANDARD_VERSIONS_PDF) $(SPECIAL_VERSIONS_PDF)

# remove temporary files
clean :
	-rm document-clean* 
	-rm document*.tbx
	-rm document*.lof
	-rm document*.bbl
	-rm document*.rel
	-rm document*.aux
	-rm document*.blg
	-rm document*Notes.bib
	-rm document*~
	-rm document*.log
	-rm *.sed.*
	-rm -rf auto/
	-rm -rf tmpdir-arXiv/
	-rm -rf tmpdir-journalX/
	-rm $(STANDARD_VERSIONS_TEX)
	-rm _region_.tex
	-rm Makefile~
	-rm images/*converted-to.*

# remove everything but sources
wipe : clean
	-rm document.pdf $(STANDARD_VERSIONS_PDF) $(SPECIAL_VERSIONS_PDF) $(SPECIAL_VERSIONS_ZIP)
	-rm document-all.tar.gz
