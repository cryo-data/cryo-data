
SHELL = bash
.DEFAULT_GOAL := help
.PHONY: help
.ONESHELL: # Applies to every targets in the file!
.SHELLFLAGS += -e # stop at first shell failure

export ds = $@
export dir = $(shell echo $$ds | cut -d" " -f1)

all: FORCE  ## Build all
	make db/*

db/*: FORCE ## Build a dataset
	# make download
	# make upload
	make install


download: ## Download data set (needs custom script per dataset)
	cd $$dir
	$(eval name=`grep "^cryo-data name" cryo-data.meta | cut -d"|" -f2 | tr -d " "`)
	datalad create -d . -D "$(name)" --force
	# datalad save cryo-data.meta cryo-data-download.sh # should maybe be in ".cryo-data" sub-folder?
	git add cryo-data.meta cryo-data-download.sh # should maybe be in ".cryo-data" sub-folder?
	git commit cryo-data.meta cryo-data-download.sh -m "cryo-data meta and download"
	if [[ -e cryo-data-download.sh ]]; then ./cryo-data-download.sh; fi
	if [[ -e cryo-data-download.py ]]; then ./cryo-data-download.py; fi

upload: ## Upload dataset
	./upload.sh $(dir)

install: ## Install dataset to cryo-data project
	./install.sh $(dir)

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

FORCE: # dummy target

clean: ## Clean
	# rm -fR G db
