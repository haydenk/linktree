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
	rm -rf .sass-cache/ _site/ node_modules/ .bundle/ vendor/bundle/ $(JS_DIR)/vendor/ fonts/

install: $(PROJECT_DEPS)
	$(BUNDLE) install --path vendor/bundle
	$(YARN) install

update: $(PROJECT_DEPS)
	$(BUNDLE) update
	$(YARN) upgrade

include-yarn-deps:
	mkdir -p $(PWD)/fonts/fa
	cp -vR node_modules/npm-font-open-sans/fonts/* $(PWD)/fonts/
	cp -vR node_modules/@fortawesome/fontawesome-free-webfonts/webfonts/* $(PWD)/fonts/fa/

build: clean install include-yarn-deps
	$(JEKYLL) build --config _config.yml,_config_prod.yml

serve: install include-yarn-deps
	$(JEKYLL) serve

test: build include-yarn-deps
	$(HTMLPROOFER) --disable-external ./_site
