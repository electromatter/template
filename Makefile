# A dependency tracking Makefile for small latex projects
#
# Copyright (c) 2017, Eric Chai <electromatter@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


# Usage:
#   Sources go into src/*.tex
#   The .pdf files are created in out/
#
# $ make clean
#   Delete out/ and tmp/
#
# $ make all
#   Compile all sources found at src/*.tex
#
# $ make out/<name>.pdf
#   Compile the specific file src/<name>.tex
#
# Recommended:
#   If you have a python installation you can use when-changed to automatically
#   invoke make. To install when-changed use the command:
# $ sudo pip install when-changed
#
#   Then to use when-changed, use:
# $ make when-changed

TEX=pdflatex
TEXOPT=-interaction=nonstopmode

SRC=$(notdir $(wildcard src/*.tex))
OUTPUTS=$(addprefix out/,$(SRC:.tex=.pdf))
DEPENDS=$(addprefix tmp/,$(SRC:.tex=.d))
WORKDIRS=out/ tmp/

.PHONY: all clean when-changed

all: $(OUTPUTS)

clean:
	rm -rf $(WORKDIRS)

when-changed:
	when-changed src/ make

$(WORKDIRS):
	mkdir $(WORKDIRS)

out/%.pdf: src/%.tex | $(WORKDIRS)
	TEXINPUTS="./src:$(TEXINPUTS)" \
		$(TEX) -recorder -output-directory=tmp/ $(TEXOPT) $<
	cp $(<:src/%.tex=tmp/%.pdf) $@
	awk '/INPUT/ { $$1=ARGV[2] ":"; print $$0 }' \
		$(<:src/%.tex=tmp/%.fls) $@ > $(<:src/%.tex=tmp/%.d)

-include $(DEPENDS)
