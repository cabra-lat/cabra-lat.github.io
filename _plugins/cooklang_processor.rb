# _plugins/cooklang_processor.rb
module Jekyll
  class CooklangGenerator < Generator
    safe true
    priority :high

    def generate(site)
      @site = site
      cooklang_dir = "_cooklang"
      output_dir = "_recipes"
      
      # Garante que os diretórios existam
      FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)
      FileUtils.mkdir_p("assets/recipes") unless Dir.exist?("assets/recipes")
      
      # Processa cada arquivo .cook
      Dir.glob(File.join(cooklang_dir, "*.cook")).each do |cook_file|
        process_cooklang_recipe(cook_file, output_dir)
      end
    end
    
    private
    
    def process_cooklang_recipe(cook_file, output_dir)
      return unless File.exist?(cook_file)
      
      basename = File.basename(cook_file, ".cook")
      content = File.read(cook_file)
      
      # Extrai metadados
      metadata = extract_metadata(content)
      
      # Converte para HTML
      html_content = convert_cooklang_to_html(content)
      
      # Cria o arquivo .md para Jekyll
      create_jekyll_recipe(basename, metadata, html_content, output_dir)
      
      # Copia o arquivo .cook original para acesso público
      FileUtils.cp(cook_file, "assets/recipes/#{basename}.cook")
    end
    
    def extract_metadata(content)
      metadata = {}
      
      if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
        yaml_content = $1
        begin
          metadata = YAML.safe_load(yaml_content) || {}
        rescue => e
          Jekyll.logger.warn "Cooklang Warning:", "Erro ao parsear YAML: #{e.message}"
        end
      end
      
      metadata
    end
    
    def convert_cooklang_to_html(content)
      # Remove o front matter para processar o conteúdo
      content_without_frontmatter = content.gsub(/\A---\s*\n.*?\n---\s*\n/m, '')
      
      # Processa a sintaxe Cooklang
      html = content_without_frontmatter
        .gsub(/@([^{}\s]+)\{([^}]+)\}/) do |match|
          name, quantity = $1, $2
          "<span class='cooklang-ingredient' data-quantity='#{quantity}'>#{name}</span>"
        end
        .gsub(/@([^{}\s]+)/) do |match|
          "<span class='cooklang-ingredient'>#{$1}</span>"
        end
        .gsub(/#([^{}\s]+)\{?\}?/) do |match|
          "<span class='cooklang-cookware'>#{$1}</span>"
        end
        .gsub(/~\{([^}]+)\}/) do |match|
          "<span class='cooklang-timer'>⏰ #{$1}</span>"
        end
        .gsub(/--\s*(.*?)\s*--/) do |match|
          "<span class='cooklang-comment'>#{$1}</span>"
        end
        .gsub(/\n\n+/, '</p><p>')  # Quebra parágrafos
        .gsub(/\n/, '<br>')        # Quebras de linha
      
      "<p>#{html}</p>"
    end
    
    def create_jekyll_recipe(basename, metadata, content, output_dir)
      # Front matter para Jekyll
      front_matter = {
        'layout' => 'recipe',
        'title' => metadata['title'] || basename.gsub('-', ' ').capitalize,
        'cooklang_source' => "/assets/recipes/#{basename}.cook"
      }.merge(metadata)
      
      # Conteúdo completo
      file_content = front_matter.to_yaml + "---\n\n" + content
      
      # Escreve o arquivo
      output_file = File.join(output_dir, "#{basename}.md")
      File.write(output_file, file_content)
    end
  end
end
