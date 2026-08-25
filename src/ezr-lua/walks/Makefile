# build the weekly walk pages (html + pdf) from anchor files + glossary
TOP    := $(shell git rev-parse --show-toplevel)
S      := /tmp/walks.$$USER
CHROME := /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
LUAW   := $(basename $(wildcard ezr-w*.lua))
PYW    := $(basename $(wildcard ezr-w*.py))

all: $(LUAW) $(PYW)

$(LUAW): %: %.lua
	@mkdir -p $(S) $(TOP)/docs/pdf
	python3 $(TOP)/etc/weekly.py $< > $(S)/$@.raw.lua
	awk -v ext=lua -f $(TOP)/etc/doc.awk $(S)/$@.raw.lua > $(S)/$@.lua
	python3 $(TOP)/etc/pyccot.py -d $(TOP)/docs $(S)/$@.lua >/dev/null
	@$(MAKE) -s css pdf-$@

$(PYW): %: %.py
	@mkdir -p $(S) $(TOP)/docs/pdf
	python3 $(TOP)/etc/weekly.py $< > $(S)/$@.py
	python3 $(TOP)/etc/pyccot.py -d $(TOP)/docs $(S)/$@.py >/dev/null
	@$(MAKE) -s css pdf-$@

pdf-%:
	@[ -x "$(CHROME)" ] && "$(CHROME)" --headless --disable-gpu \
	  --print-to-pdf=$(TOP)/docs/pdf/$*.pdf --no-pdf-header-footer \
	  file://$(TOP)/docs/$*.html 2>/dev/null || true

slides: $(addprefix slide-,$(LUAW) $(PYW))  ## beamer decks

slide-%:
	@mkdir -p $(S) $(TOP)/docs/slides
	python3 $(TOP)/etc/slides.py $(wildcard $*.lua $*.py) > $(S)/$*-s.md
	pandoc -t beamer --pdf-engine=tectonic --slide-level=2 \
	  -V fontsize=10pt -V aspectratio=169 -V theme=default \
	  -V colortheme=dove $(S)/$*-s.md -o $(TOP)/docs/slides/$*.pdf \
	  2>/dev/null

css:  ## every pyccot run clobbers pycco.css; restore the extras
	@grep -q 'timm extras' $(TOP)/docs/pycco.css || \
	  cat $(TOP)/etc/pycco-extras.css >> $(TOP)/docs/pycco.css
