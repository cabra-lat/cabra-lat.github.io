.PHONY: all

all: install build gen-previews

install:
	bundle install --local

build:
	bundle exec jekyll build

gen-previews:
	node .github/workflows/generate_previews.js

serve:
	bundle exec jekyll serve --verbose

post:
	node .github/bluesky_post.js


