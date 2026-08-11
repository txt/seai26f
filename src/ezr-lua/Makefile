# vim: ts=8 noexpandtab :
# Inside the repo, this pulls in the root Makefile as well
# (doc, eg, push, ...). Inside ezr-lua.zip there is no repo,
# so that include silently vanishes and only the targets
# below exist. Everything here needs lua and nothing else.
-include $(shell git rev-parse --show-toplevel 2>/dev/null)/Makefile

LUA   ?= lua
CORES ?= 4
MOOT  ?= moot
L     ?= 1
CSV   := $(filter-out $(MOOT)/optimize/test/%, \
           $(wildcard $(MOOT)/optimize/*/*.csv))
FILES := ezr.lua ezr-lib.lua ezr-eg.lua ezr-apps.lua \
         ezr-dtlz.lua play.lua Makefile tut.md README.md \
         data/auto93.csv etc/img/fig2-w2.png etc/tut/repl.lua \
         $(wildcard etc/tut/*.in)

.DEFAULT_GOAL := usage

usage: ## show these targets
	@grep -hE '^[a-z-]+:.*## ' Makefile | \
	  awk -F':.*## ' '{printf "  \033[36m%-8s\033[0m %s\n",$$1,$$2}'

repl: ## the tutorial prompt (same as: lua -i play.lua)
	@$(LUA) -i play.lua

demo: ## run every demo; each must end "failures: 0"
	@$(LUA) ezr-eg.lua   --all
	@$(LUA) ezr-apps.lua --all
	@$(LUA) ezr-dtlz.lua --all

apps: ## higher-level demos only: knn, nb, kmeans, ga/de/sa/ls, race, dtlz
	@$(LUA) ezr-apps.lua --all
	@$(LUA) ezr-dtlz.lua --all

csv: ## e.g. read a table; row 1 is the header
	lua ezr-eg.lua --file=data/auto93.csv --csv

col: ## e.g. one Num and one Sym summary
	lua ezr-eg.lua --file=data/auto93.csv --col

disty: ## e.g. sort all rows by distance to heaven; show ends
	lua ezr-eg.lua --file=data/auto93.csv --disty

half: ## e.g. split rows on two far poles, best half first
	lua ezr-eg.lua --file=data/auto93.csv --half

node: ## e.g. cluster: recursive tree of halves
	lua ezr-eg.lua --file=data/auto93.csv --node

show: ## e.g. grow a best-cut tree and print it
	lua ezr-eg.lua --file=data/auto93.csv --show

acquire: ## e.g. spend the label budget; best found vs truth
	lua ezr-eg.lua --file=data/auto93.csv --acquire

holdout: ## e.g. train on half, test on the unseen half
	lua ezr-eg.lua --file=data/auto93.csv --holdout

lecture: ## replay one lecture's trace (make lecture L=3)
	@EZR=$$PWD $(LUA) etc/tut/repl.lua etc/tut/l$(L).in

TUT := tut/front.md tut/l0.md tut/l1.md tut/l2.md tut/l3.md \
       tut/l4.md tut/l5.md tut/l6.md tut/l7.md tut/l8.md \
       tut/l9.md tut/l10.md tut/lua101.md
RELEASED ?=
tut.md: $(TUT) tut/glossary.md tut/refs.md ## weave tut/ parts into tut.md (RELEASED=k adds answers 1..k)
	@{ cat $(TUT); \
	   if [ -n "$(RELEASED)" ]; then \
	     printf '<a name="answers"></a>\n# Exam answers\n\n'; \
	     for i in $$(seq 1 $(RELEASED)); do cat tut/ans/a$$i.md; echo; done; \
	     printf '[contents](#contents)\n\n---\n\n'; fi; \
	   cat tut/glossary.md tut/refs.md; } > $@
	@wc -l $@

PLAYERS := moot/optimize/behavior_data/all_players.csv
RAW := https://raw.githubusercontent.com/timm/moot/master

players: $(PLAYERS) ## fetch just the Lecture 0 table (3.6MB)
$(PLAYERS):
	@mkdir -p $(dir $@)
	curl -fL -o $@ $(RAW)/optimize/behavior_data/all_players.csv

data: ## fetch the whole moot corpus into ./moot (~200MB)
	curl -fL -o moot.zip \
	  https://github.com/timm/moot/archive/refs/heads/master.zip
	unzip -q moot.zip && rm moot.zip && mv moot-master $(MOOT)

one: ## one table (make one F=moot/optimize/misc/auto93.csv)
	@$(LUA) ezr-eg.lua --file=$(F) --holdout

all: ## every table, CORES at a time, into results.tsv
	@test -n "$(CSV)" || { echo "no data: make data"; exit 1; }
	@echo "$(words $(CSV)) tables, $(CORES) at a time ..."
	@printf '%s\n' $(CSV) | xargs -P $(CORES) -I{} sh -c \
	  'printf "%s\t%s\n" "$$(basename {} .csv)" \
	     "$$($(LUA) ezr-eg.lua --file={} --holdout)"' \
	  | sort > results.tsv
	@echo "$$(wc -l < results.tsv) rows -> results.tsv"

zip: ezr-lua.zip ## bundle the course into ezr-lua.zip

ezr-lua.zip: $(FILES) ../LICENSE.md
	@rm -f $@
	@d=$$(mktemp -d); mkdir -p $$d/ezr-lua; \
	 tar cf - $(FILES) | (cd $$d/ezr-lua && tar xf -); \
	 cp ../LICENSE.md $$d/ezr-lua/; \
	 (cd $$d && zip -qX -r $(CURDIR)/$@ ezr-lua); \
	 rm -rf $$d
	@unzip -l $@ | tail -1 | sed 's/^/  /'
