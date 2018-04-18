SHELL := /bin/bash
BUNDLE := bundle
YARN := yarn
JEKYLL := $(BUNDLE) exec jekyll
HTMLPROOFER := $(BUNDLE) exec htmlproofer
CSS_DIR := css/
JS_DIR := js/
VENDOR_DIR := vendor/
DEPLOY_REPO="https://${DEPLOY_TOKEN}@github.com/haydenk/linktree.git"

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

build: clean install
	$(JEKYLL) build

serve: install
	$(JEKYLL) serve

test: build
	$(HTMLPROOFER) --http-status-ignore "302,403" ./_site

deploy:
	echo ${DEPLOY_REPO}