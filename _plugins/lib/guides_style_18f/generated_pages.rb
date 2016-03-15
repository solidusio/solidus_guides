require_relative './layouts'

module GuidesStyle18F
  class GeneratedPages
    DEFAULT_LAYOUT = 'guides_style_18f_generated_home_redirect'

    def self.generate_pages_from_navigation_data(site)
      layout = site.config['generate_nodes']
      return if layout.nil? || layout == false
      layout = DEFAULT_LAYOUT if layout == true
      nav_data = site.config['navigation']
      generate_pages_from_generated_nodes(site, layout, nav_data, '/')
    end

    def self.generate_pages_from_generated_nodes(
      site, layout, nav_data, parent_url)
      (nav_data || []).select { |nav| nav['generated'] }.each do |nav|
        site.pages << GeneratedPage.new(site, layout, nav, parent_url)
        children = nav['children']
        next_url = parent_url + nav['url']
        generate_pages_from_generated_nodes(site, layout, children, next_url)
      end
    end
  end

  class GeneratedPage < ::Jekyll::Page
    def initialize(site, layout, nav, parent_url)
      @site = site
      @name = 'index.html'

      process(@name)
      @data = {}
      data['title'] = nav['text']
      data['permalink'] = parent_url + nav['url']
      data['layout'] = layout
    end
  end
end
