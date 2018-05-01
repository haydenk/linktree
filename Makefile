SHELL := /bin/bash
BUNDLE := bundle
YARN := yarn
JEKYLL := $(BUNDLE) exec jekyll
HTMLPROOFER := $(BUNDLE) exec htmlproofer
CSS_DIR := css
JS_DIR := js

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
	rm -rf .sass-cache/ _site/ node_modules/ .bundle/ vendor/bundle/ $(JS_DIR)/vendor/

install: $(PROJECT_DEPS)
	$(BUNDLE) install --path vendor/bundle
	$(YARN) install

update: $(PROJECT_DEPS)
	$(BUNDLE) update
	$(YARN) upgrade

include-yarn-deps:
	mkdir -p $(VENDOR_DIR)
	cp node_modules/jquery/dist/jquery.min.* $(JS_DIR)/vendor/
	cp node_modules/popper.js/dist/umd/popper.min.* $(JS_DIR)/vendor/
	cp node_modules/bootstrap/dist/js/bootstrap.min.* $(JS_DIR)/vendor/

build: install
	$(JEKYLL) build --config _config.yml,_config_prod.yml

serve: install
	$(JEKYLL) serve

test: build
	$(HTMLPROOFER) --disable-external ./_site
