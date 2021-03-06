URL = www.seedramp.com
HTML = $(patsubst pages/%.haml, target/%.html, $(wildcard pages/[^_]*.haml))
DEPS = $(wildcard pages/[_]*.haml)
CSS_DEPS = $(wildcard sass/[_]*.scss)
LOG = target/log/2016/02/20/LegalRobot.html
CSS = $(patsubst sass/%.scss, target/css/%.css, $(wildcard sass/[^_]*.scss))
IMAGES = $(patsubst images/%, target/images/%, $(wildcard images/*))

all: target lint site

target:
	mkdir -p target

target/css/scsslint: $(CSS)
	scss-lint -c .scss-lint.yml
	touch target/css/scsslint

target/CNAME: target
	echo "$(URL)" > target/CNAME

target/sitemap.xml: make-sitemap.rb $(HTML)
	./make-sitemap.rb > target/sitemap.xml

target/rss.xml: make-rss.rb $(HTML)
	./make-rss.rb > target/rss.xml

target/robots.txt: target
	echo "" > target/robots.txt

target/images/%: images/% target
	mkdir -p target/images
	cp $< $@

target/%.html: pages/%.haml target $(DEPS)
	haml --style=indented $< > $@

target/css/%.css: sass/%.scss target $(CSS_DEPS)
	mkdir -p target/css
	sass --style=compressed --sourcemap=none $< $@

target/log/%.html: log/%.md target $(DEPS) make-log.rb
	mkdir -p `dirname $@`
	./make-log.rb $< > $@

site: $(HTML) $(CSS) $(IMAGES) $(LOG) target/CNAME target/robots.txt target/sitemap.xml target/rss.xml

lint: target/css/scsslint

clean:
	rm -rf target

