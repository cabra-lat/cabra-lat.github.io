module Jekyll
  class AssetsPathGenerator < Generator
    priority :low

    def generate(site)
      # Process posts
      site.posts.docs.each do |post|
        post.data['assets'] = generate_assets_path(post)
        puts "Generated assets path for post #{post.data['title']}: #{post.data['assets']}"
      end

      # Process previews collection, if it exists
      if site.collections.key?('previews')
        site.collections['previews'].docs.each do |preview|
          preview.data['assets'] = generate_assets_path(preview)
          preview.data['layout'] = 'preview'
          puts "Generated assets path for preview #{preview.data['title']}: #{preview.data['assets']}"
        end
      end
    end

    private

    def generate_assets_path(document)
      if document.data['date']
        date = document.data['date']
        year = date.strftime('%Y')
        month = date.strftime('%m')
        day = date.strftime('%d')
        return "assets/#{year}/#{month}/#{day}"
      end
      # Default assets path for items without a date
      "assets/default"
    end
  end
end
