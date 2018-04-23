SHELL := /bin/bash
BUNDLE := bundle
YARN := yarn
JEKYLL := $(BUNDLE) exec jekyll
HTMLPROOFER := $(BUNDLE) exec htmlproofer
CSS_DIR := css
JS_DIR := js
VENDOR_DIR := vendor
GIT_VERSION = $(shell git describe --tags --dirty --always)

PROJECT_DEPS := Gemfile Gemfile.lock package.json yarn.lock

.PHONY: all clean install update

all: serve _site _site/index.html

check:
	$(JEKYLL) doctor
	$(HTMLPROOF) --check-html \
		--http-status-ignore 999 \
		--internal-domains localhost:4000 \
		--assume-extension \
		_site

clean:
	rm -rf .sass-cache/ _site/ node_modules/ .bundle/ vendor/bundle/ $(JS_DIR)/$(VENDOR_DIR)/

install: $(PROJECT_DEPS)
	$(BUNDLE) install --path vendor/bundle
	$(YARN) install

update: $(PROJECT_DEPS)
	$(BUNDLE) update
	$(YARN) upgrade

include-yarn-deps:
	mkdir -p $(VENDOR_DIR)
	cp node_modules/jquery/dist/jquery.min.* $(JS_DIR)/$(VENDOR_DIR)
	cp node_modules/popper.js/dist/umd/popper.min.* $(JS_DIR)/$(VENDOR_DIR)/
	cp node_modules/bootstrap/dist/js/bootstrap.min.* $(JS_DIR)/$(VENDOR_DIR)/

build: install
	$(JEKYLL) build --config `ls -dm _config*yml|tr -d ' '`

serve: install
	$(JEKYLL) serve

test: build
	$(HTMLPROOFER) --http-status-ignore "302,403" ./_site

deploy:
	git tag $(GIT_VERSION)
	export VERSION=$(GIT_VERSION)
	tar -C _site -cjf linktree-${GIT_VERSION}.tar.bz2 .
