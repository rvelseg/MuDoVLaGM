# MuDoVLaGM: Multiple Document Versions using LaTeX and GNU Make

This set of scripts attepmt to solve the following problem. While you
are writing a document (for me the motivation was a scientific paper)
you need an output format that looks good in you screen. When you want
someone to make comments on your work it could be good to have it in a
printing friendly format or in a tablet friendly format. When you
finally want to sumbit it for publication (to a journal), the required
format could have several diferences with your present versions. And,
if you want to submit it to the arXiv other format changes could be
required. Then, it is not trivial to have text files with the
appropriate format commands without duplicating the body of text, and
that could be a problem when making changes.

Since this acronym `MuDoVLaGM` is still too long, we use `MD`.

# Approach of the solution

Use a single file `document.tex` that contains the body of document and the
format commands for all the versions you need. The format commands are
commented inside `document.tex`, with marks (also commented) that allows
the fomat commands to be selectively uncommented when building a
specific version of the document. To achieve this the compilation is
performed using a `make` command in the following way:

    make document-tablet.pdf
	
in this case `tablet` is the name of the version, and this name could
be whatever you want. Inside `document.tex` there are lines like

    %%% \MDbegin{tablet}
	%% This is the conditional class command for tablet version
	% \documentclass[a5paper]{article}
	%%% \MDend{tablet}
	
that will be compiled as

    \documentclass[a5paper]{article}
	
note that between `MDbegin`, and `MDend` are lines starting with
`%%` that are not attempted to be compiled. The pairs `MDbegin`
`MDend` can be placed anywhere inside `document.tex`.

To allow the posibility to compile `document.tex` in the usual way

    pdflatex document.tex
	
it is possible to have lines like 

    %%% \MDbegin{phone}
	%% This is the default class for document.tex
	\documentclass[a5paper]{article}
	%%% \MDend{phone}

The process `make document-tablet.pdf` will comment everything between
any pair `MDbegin` `MDend` that does not has the word `tablet`
inside their braces. Note that a `MDbegin` `MDend` block could
apply to multiple vesions, e.g.

	%%% \MDbegin{preprint twoColumnA arXiv}
	% \title[Finite volume nonlinear acoustic propagation]{A finite volume approach for the simulation of nonlinear dissipative acoustic wave propagation} 
	%
	% \author{Roberto Velasco-Segura}
	% \author{Pablo L. Rend\'{o}n}
	%%% \MDend{preprint twoColumnA arXiv}

# Special versions

Some versions of the document could require special formats for images,
file naming, directory structure, packing, etc. All the needed
commands to solve this requirements can be placed in a special recipe
inside the `Makefile`, to avoid confusion with the standard versions
the `\documentclass` command for these special versions must be
between a pair `MDbegin*` `MDend*`, i.e.

	%%% \MDbegin*{arXiv}
	% \documentclass[nopreprint]{jasatex}
	% \usepackage{amssymb}
	% \usepackage{amsmath}
	% \usepackage{graphicx}
	% \usepackage[utf8]{inputenc}
	% \usepackage{setspace}
	% \usepackage{multirow}
	% \usepackage{url} 
	%%% \MDend*{arXiv}

A couple of examples of recipes for special versions are given in the
present `Makefile`.

# Making your own versions

If you want to add a standard version, say `other`, all you have to do
is add a block

	%%% \MDbegin{other}
	% \documentclass{article}
	%%% \MDend{other}

having the `\documentclass` for your version, and maybe some other
header commands, this block should be placed before the
`\begin{document}` command. After that, add as many `MDbegin`
`MDend` blocks as needed, in the body of `document.tex`.

If you want to add a special version, you have to do what you would do
for a standard version, but adding a `*` symbol in the block that goes
before `\begin{document}` like this

	%%% \MDbegin*{other}
	% \documentclass{article}
	%%% \MDend*{other}
	
other blocks in the body of `document.tex` don't need the `*`
symbol. After that, you have to write a recipe in the `Makefile`, say
for `other.zip`. And see the code for general recipes `clean` `all`,
`pack`, etc. in case you want to place something there.  I recommend
to create a directories under `special_versions`, and place there all
the extra information needed for these versions.

# System Requirements

Some standard linux command line tools

* make 
* perl 
* sed
* tar

A LaTeX distribution to execute the following commands 

* pdflatex
* bibtex
* de-macro

A few extra tools 

* pdfcrop
* zip

Some LaTeX packages to build the example

* natbib
* url 

# Additional features

## Removing comments

Many times one have personal comments that are not desirable in the
distributed versions of the source code. In this particular case, all
the commented commands for other versions. Commands in `Makefile` make
use of a script

    removeLatexComments.pl

that remove the comments. This script has been taken from

    http://tex.stackexchange.com/questions/83663/utility-to-strip-comments-from-latex-source

## Custom macros

Many of the journals compile your paper during the submission process,
and many times this compiler doesn't like your custom macros, but
while writing it's much faster to use custom macros. The `de-macro`
command can be used to solve this problem, it simply generates a new
`.tex` file where the custom macros are substituted with their
definitions. Commands in the `Makefile` make use of `de-macro`, but
your custom macros should be defined in `my-private.sty` and not in
`document.tex`.

By now I have used this with `\newcommand` only. It could work with
`\renewcommand`, `\newenvironment`, etc. but I have not tested it.

## bib-at-work

When writing sometimes it's useful to make notes of the references you
need to search later, if you write that notes like
`\cite{theOneWithManyPlots}` this simple script `bib-at-work.sty` will
display the missing key in you compiled version. It can also make a
list of missing keys and a list of non cited references.

This script has been taken from

    http://tex.stackexchange.com/questions/123093/replacing-with-citation-key-and-or-making-list-of-unresolved-references-in-nat

## Other make commands

Use `make clean` to remove temporary files, but not final products,
like `.pdf` files.

Use `make wipe` to remove everything but source files.

Use `make list` to list the available versions in `document.tex`. 

Use `make all` to make all versions

Use `make pack` to make all versions and pack them in a `.tar.gz` file

# License

See `LICENSE.txt`
