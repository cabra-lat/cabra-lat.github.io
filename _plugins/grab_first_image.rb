module Jekyll
  module ExtractFirstImageFilter
    def extract_first_image(content)
      match = content.match(/<img[^>]+src=['"]([^'"]+)['"]/)
      match ? match[1] : nil
    end
  end
end

Liquid::Template.register_filter(Jekyll::ExtractFirstImageFilter)
