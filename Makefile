SHELL := /bin/bash
BUNDLE := bundle
YARN := yarn
JEKYLL := $(BUNDLE) exec jekyll
CSS_DIR := css/
JS_DIR := js/
VENDOR_DIR := vendor/

PROJECT_DEPS := Gemfile Gemfile.lock package.json yarn.lock

.PHONY: all clean install update

all : serve

check:
	$(JEKYLL) doctor
	$(HTMLPROOF) --check-html \
		--http-status-ignore 999 \
		--internal-domains localhost:4000 \
		--assume-extension \
		_site

clean:
	rm -rf .sass-cache/ _site/ node_modules/ .bundle/ gems/ ${JS_DIR}/vendor/

install: $(PROJECT_DEPS)
	$(BUNDLE) install --path /vendor/bundle
	$(YARN) install

update: $(PROJECT_DEPS)
	$(BUNDLE) update
	$(YARN) upgrade

include-yarn-deps:
	mkdir -p $(VENDOR_DIR)
	cp node_modules/jquery/dist/jquery.min.* $(VENDOR_DIR)
	cp node_modules/popper.js/dist/umd/popper.min.* $(VENDOR_DIR)
	cp node_modules/bootstrap/dist/js/bootstrap.min.* $(VENDOR_DIR)

build: clean install
	$(JEKYLL) build

serve: install
	$(JEKYLL) serve
