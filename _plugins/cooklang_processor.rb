module Jekyll
  class CooklangGenerator < Generator
    safe true
    priority :high

    def generate(site)
      # Configurações
      cooklang_dir = "_cooklang"
      output_dir = "_recipes"
      public_recipes_dir = "assets/recipes"
      
      # Garante que os diretórios existam
      FileUtils.mkdir_p(output_dir)
      FileUtils.mkdir_p(public_recipes_dir)
      
      # Processa cada arquivo .cook
      Dir.glob(File.join(cooklang_dir, "*.cook")).each do |cook_file|
        process_cooklang_recipe(site, cook_file, output_dir, public_recipes_dir)
      end
    end
    
    private
    
    def process_cooklang_recipe(site, cook_file, output_dir, public_recipes_dir)
      basename = File.basename(cook_file, ".cook")
      
      # Lê o conteúdo do arquivo .cook
      content = File.read(cook_file)
      
      # Extrai metadados do front matter
      metadata = extract_metadata(content)
      
      # Converte para HTML/Markdown
      html_content = convert_cooklang_to_html(content)
      
      # Cria o arquivo .md para Jekyll
      create_jekyll_recipe(site, basename, metadata, html_content, output_dir)
      
      # Copia o arquivo .cook original para acesso público
      FileUtils.cp(cook_file, File.join(public_recipes_dir, "#{basename}.cook"))
    end
    
    def extract_metadata(content)
      metadata = {}
      
      # Extrai o front matter YAML
      if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
        yaml_content = $1
        begin
          metadata = YAML.safe_load(yaml_content)
        rescue => e
          Jekyll.logger.warn "Cooklang Warning:", "Erro ao parsear YAML: #{e.message}"
        end
      end
      
      metadata
    end
    
    def convert_cooklang_to_html(content)
      # Remove o front matter para processar o conteúdo
      content_without_frontmatter = content.gsub(/\A---\s*\n.*?\n---\s*\n/m, '')
      
      # Processa ingredientes, cookware e timers
      html = content_without_frontmatter
        .gsub(/@(\w+(?:\s+\w+)*)\{([^}]+)\}/) do |match|
          name, quantity = $1, $2
          "<span class='cooklang-ingredient' data-quantity='#{quantity}'>#{name}</span>"
        end
        .gsub(/#(\w+(?:\s+\w+)*)\{?\}?/) do |match|
          "<span class='cooklang-cookware'>#{$1}</span>"
        end
        .gsub(/~\{([^}]+)\}/) do |match|
          "<span class='cooklang-timer'>⏰ #{$1}</span>"
        end
        .gsub(/--\s*(.*?)\s*--/) do |match|
          "<span class='cooklang-comment'>#{$1}</span>"
        end
      
      html
    end
    
    def create_jekyll_recipe(site, basename, metadata, content, output_dir)
      # Prepara o front matter para Jekyll
      front_matter = {
        'layout' => 'recipe',
        'title' => metadata['title'] || basename.gsub('-', ' ').capitalize,
        'cooklang_source' => "/assets/recipes/#{basename}.cook"
      }.merge(metadata)
      
      # Conteúdo completo do arquivo
      file_content = front_matter.to_yaml + "---\n\n" + content
      
      # Cria o arquivo .md
      output_file = File.join(output_dir, "#{basename}.md")
      File.write(output_file, file_content)
      
      # Adiciona à coleção do site
      site.collections['recipes'] ||= Jekyll::Collection.new(site, 'recipes')
      site.collections['recipes'].docs << Jekyll::Document.new(output_file, site: site, collection: site.collections['recipes'])
    end
  end
end
