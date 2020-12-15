.PHONY : clean distclean start-build start-server

# REVEALJS_SHA := 0582f57517c97a4c7bfeb58762138c78883f94c5
REVEALJS_VERSION := 4.1.0
REVEALJS_CDN_BASE_URL := https://cdn.jsdelivr.net/npm/reveal.js
REVEALJS_CDN_VERSIONED_BASE_URL := https://cdn.jsdelivr.net/npm/reveal.js\@$(REVEALJS_VERSION)

REVEAL_PORT ?= 8002
SRC_DIR := src
REVEALJS_DIR := reveal.js
REVEALJS_INDEX := $(REVEALJS_DIR)/index.html

SRC_IMAGES_DIR := $(SRC_DIR)/images
SRC_IMAGES := $(wildcard $(SRC_IMAGES_DIR)/*)
REVEALJS_IMAGES_DIR := $(REVEALJS_DIR)/images
REVEALJS_IMAGES := $(patsubst $(SRC_IMAGES_DIR)/%,$(REVEALJS_IMAGES_DIR)/%,$(SRC_IMAGES))
REVEALJS_CSS := reveal.js/css/local.css reveal.js/css/theme/source/grzm.scss

all : reveal.js $(REVEALJS_INDEX) css images

$(REVEALJS_INDEX) : src/index.html
	cp src/index.html reveal.js/
	perl -p -i -e 's|https://cdn.jsdelivr.net/npm/reveal.js/dist/theme/grzm.css|/dist/theme/grzm.css|g' $(REVEALJS_INDEX)
	perl -p -i -e 's|zoom-js/zoom.js|zoom/zoom.js|g' $(REVEALJS_INDEX)
	perl -p -i -e 's|$(REVEALJS_CDN_BASE_URL)|$(REVEALJS_CDN_VERSIONED_BASE_URL)|g' $(REVEALJS_INDEX)

css : $(REVEALJS_CSS)

reveal.js/css/local.css : src/css/local.css
	cp $< $@

reveal.js/css/theme/source/grzm.scss : src/css/theme/source/grzm.scss
	cp $< $@

reveal.js :
	git clone https://github.com/hakimel/reveal.js.git
	cd reveal.js && \
		git checkout --quiet $(REVEALJS_VERSION) && \
		npm install

$(REVEALJS_IMAGES_DIR) :
	mkdir -p $(REVEALJS_IMAGES_DIR)

images : $(REVEALJS_IMAGES_DIR) $(REVEALJS_IMAGES)

$(REVEALJS_IMAGES_DIR)/% : $(SRC_IMAGES_DIR)/%
	cp $< $@

watch-build :
	find src | entr make

start-server:
	cd reveal.js && npm start -- --port $(REVEAL_PORT)

clean :
	-rm $(REVEALJS_INDEX) $(REVEALJS_CSS)

distclean :
	-rm -rf reveal.js
