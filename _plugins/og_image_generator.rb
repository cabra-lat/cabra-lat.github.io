module Jekyll
  class OgImageGenerator < Generator
    priority :low

    def generate(site)
      Jekyll.logger.debug "OgImageGenerator", "Plugin loaded successfully"

      # Path to the external template
      template_path = File.join(site.source, "_templates/og-template.html")

      unless File.exist?(template_path)
        Jekyll.logger.error "OgImageGenerator", "Template not found: #{template_path}"
        return
      end

      # Load the template file
      template = File.read(template_path)
      output_dir = ("og-images")
      FileUtils.mkdir_p(output_dir)

      Jekyll.logger.info "OgImageGenerator", "Processing posts"
      site.posts.docs.each do |post|
        # Skip posts explicitly opting out
        next if post.data["og_skip"]

        slug = post.data["slug"] || post.basename_without_ext
        html_output_path = File.join(output_dir, "#{slug}.html")

        # Prepare variables for Liquid rendering (do not modify `site_payload`)
        context = {
          "page" => post.to_liquid,
          "site" => site.site_payload["site"]
        }

        # Render the template with Liquid
        rendered_html = site.liquid_renderer.file(template_path).parse(template).render!(context)

        # Write the rendered HTML file
        File.write(html_output_path, rendered_html)
        Jekyll.logger.info "OgImageGenerator", "OG Image HTML generated at #{html_output_path}"
      end
    end
  end
end
