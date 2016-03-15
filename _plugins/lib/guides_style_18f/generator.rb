# @author Mike Bland (michael.bland@gsa.gov)

require_relative './assets'
require_relative './breadcrumbs'
require_relative './generated_pages'
require_relative './layouts'
require_relative './namespace_flattener'

require 'jekyll'

module GuidesStyle18F
  class Generator < ::Jekyll::Generator
    def generate(site)
      Layouts.register(site)
      Assets.copy_to_site(site)
      GeneratedPages.generate_pages_from_navigation_data(site)
      pages = site.collections['pages']
      docs = (pages.nil? ? [] : pages.docs) + site.pages
      Breadcrumbs.generate(site, docs)
      NamespaceFlattener.flatten_url_namespace(site, docs)
    end
  end
end
