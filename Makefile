.PHONY: all

all: install build gen-previews

# Create a new blog post
# Usage: make post TITLE="My New Post"
post:
	@if [ -z "$(TITLE)" ]; then echo "Usage: make post TITLE=\"Your Post Title\""; exit 1; fi
	@python3 -c "import datetime, os, re; t='$(TITLE)'; s=re.sub(r'[^a-zA-Z0-9]+','-',t.lower()).strip('-'); f='_posts/'+datetime.datetime.now().strftime('%Y-%m-%d')+'-'+s+'.md'; os.path.exists(f) and (print('Post already exists: '+f), exit(1)); open(f,'w').write('---\nlayout: post\ntitle: \"'+t+'\"\ndate: '+datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S %z')+'\n---\n\nYour content here\n'); print('Post created: '+f)"
	@$${EDITOR:-nvim} $$f

install:
	bundle install --local

build: gen-recipes
	bundle exec jekyll build

gen-previews:
	node .github/workflows/generate_previews.js

gen-recipes:
	@echo "Convertendo receitas Cooklang para Markdown..."
	@which cook >/dev/null 2>&1 || (echo "CookCLI nao encontrado. Instalando..."; \
		curl -L https://github.com/cooklang/cookcli/releases/latest/download/cook-x86_64-unknown-linux-gnu.tar.gz -o cook.tar.gz && \
		tar -xzf cook.tar.gz && \
		sudo mv cook /usr/local/bin/ && \
		rm cook.tar.gz)
	@mkdir -p _recipes
	@for recipe in assets/recipes/*.cook; do \
		if [ -f "$$recipe" ]; then \
			basename=$$(basename "$$recipe" .cook); \
			echo "Convertendo: $$basename.cook -> _recipes/$$basename.md"; \
			cook recipe -f markdown "$$recipe" > "_recipes/$$basename.md"; \
		fi; \
	done
	@echo "Conversao de receitas concluida!"

serve: gen-recipes
	bundle exec jekyll serve --verbose --livereload

# Post to Bluesky
broadcast:
	node .github/bluesky_post.js

# Alias for backwards compatibility
post-bluesky:
	node .github/bluesky_post.js

clean-recipes:
	@echo "Limpando receitas convertidas..."
	@rm -f _recipes/*.md
	@echo "Limpeza concluida!"

# Alias para compatibilidade
recipes: gen-recipes