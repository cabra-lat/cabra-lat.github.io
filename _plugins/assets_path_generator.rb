module Jekyll
  class AssetsPathGenerator < Generator
    priority :low

    def generate(site)
      site.posts.docs.each do |post|
        if post.data['date']
          date = post.data['date']
          year = date.strftime('%Y')
          month = date.strftime('%m')
          day = date.strftime('%d')
          post.data['assets'] = "assets/#{year}/#{month}/#{day}"
          puts "Generated assets path for #{post.data['title']}: #{post.data['assets']}"
        end
      end
    end
  end
end
