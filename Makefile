.PHONY: all

all: install build gen-previews

install:
	bundle install --local

build: gen-recipes
	bundle exec jekyll build

gen-previews:
	node .github/workflows/generate_previews.js

gen-recipes:
	@echo "📝 Convertendo receitas Cooklang para Markdown..."
	@which cook >/dev/null 2>&1 || (echo "❌ CookCLI não encontrado. Instalando..."; \
		curl -L https://github.com/cooklang/cookcli/releases/latest/download/cook-x86_64-unknown-linux-gnu.tar.gz -o cook.tar.gz && \
		tar -xzf cook.tar.gz && \
		sudo mv cook /usr/local/bin/ && \
		rm cook.tar.gz)
	@mkdir -p _recipes
	@for recipe in assets/recipes/*.cook; do \
		if [ -f "$$recipe" ]; then \
			basename=$$(basename "$$recipe" .cook); \
			echo "🔨 Convertendo: $$basename.cook -> _recipes/$$basename.md"; \
			cook recipe -f markdown "$$recipe" > "_recipes/$$basename.md"; \
		fi; \
	done
	@echo "✅ Conversão de receitas concluída!"

serve: gen-recipes
	bundle exec jekyll serve --verbose --livereload

post:
	node .github/bluesky_post.js

clean-recipes:
	@echo "🧹 Limpando receitas convertidas..."
	@rm -f _recipes/*.md
	@echo "✅ Limpeza concluída!"

# Alias para compatibilidade
recipes: gen-recipes
