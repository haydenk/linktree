SHELL := /bin/bash
BUNDLE := bundle
YARN := yarn
JEKYLL := $(BUNDLE) exec jekyll
HTMLPROOFER := $(BUNDLE) exec htmlproofer
CSS_DIR := css/
JS_DIR := js/
VENDOR_DIR := vendor/
VERSION = $(shell git describe --tags --dirty --always)

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
	rm -rf .sass-cache/ _site/ node_modules/ .bundle/ _vendor/bundle/

install: $(PROJECT_DEPS)
	$(BUNDLE) install --path _vendor/bundle
	$(YARN) install

update: $(PROJECT_DEPS)
	$(BUNDLE) update
	$(YARN) upgrade

include-yarn-deps:
	mkdir -p $(VENDOR_DIR)
	cp node_modules/jquery/dist/jquery.min.* $(VENDOR_DIR)
	cp node_modules/popper.js/dist/umd/popper.min.* $(VENDOR_DIR)
	cp node_modules/bootstrap/dist/js/bootstrap.min.* $(VENDOR_DIR)

build: install
	$(JEKYLL) build --config `ls -dm _config*yml|tr -d ' '`

serve: install
	$(JEKYLL) serve

test: build
	$(HTMLPROOFER) --http-status-ignore "302,403" ./_site

deploy:
	git config --local user.name "Travis CI"
	git config --local user.email "hayden.king@gmail.com"
	git tag ${VERSION}
	tar -C _site -cjf linktree-${VERSION}.tar.bz2 .

tarball:
	echo linktree-${VERSION}.tar.bz2