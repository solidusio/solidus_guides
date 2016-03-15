module GuidesStyle18F
  class GeneratedNodes
    # Params:
    #   url_to_nav: Mapping from original document URL to "nav item" objects,
    #     i.e. { 'text' => '...', 'url' => '...', 'internal' => true }
    #   nav_data: Array of nav item objects contained in `url_to_nav` after
    #     applying updates, possibly containing "orphan" items marked with an
    #     `:orphan_url` property
    #
    # Returns:
    #   nav_data with orphans properly nested within automatically-generated
    #     parent nodes marked with `'generated' => true`
    def self.create_homes_for_orphans(url_to_nav, nav_data)
      orphans = nav_data.select { |nav| nav[:orphan_url] }
      orphans.each { |nav| create_home_for_orphan(nav, nav_data, url_to_nav) }
      nav_data.reject! { |nav| nav[:orphan_url] }
      prune_childless_parents(nav_data)
    end

    def self.create_home_for_orphan(nav, nav_data, url_to_nav)
      parents = nav[:orphan_url].split('/')[1..-1]
      nav['url'] = parents.pop + '/'
      child_url = '/'
      immediate_parent = parents.reduce(nil) do |parent, child|
        child_url = child_url + child + '/'
        find_or_create_node(nav_data, child_url, parent, child, url_to_nav)
      end
      assign_orphan_to_home(nav, immediate_parent, url_to_nav)
    end

    def self.find_or_create_node(nav_data, child_url, parent, child, url_to_nav)
      child_nav = url_to_nav[child_url]
      if child_nav.nil?
        child_nav = generated_node(child)
        url_to_nav[child_url] = child_nav
        (parent.nil? ? nav_data : (parent['children'] ||= [])) << child_nav
      end
      child_nav
    end

    def self.generated_node(parent_slug)
      { 'text' => parent_slug.split('-').join(' ').capitalize,
        'url' => parent_slug + '/',
        'internal' => true,
        'generated' => true,
      }
    end

    def self.assign_orphan_to_home(nav, immediate_parent, url_to_nav)
      nav_copy = {}.merge(nav)
      url_to_nav[nav_copy.delete(:orphan_url)] = nav_copy
      (immediate_parent['children'] ||= []) << nav_copy
    end

    def self.prune_childless_parents(nav_data)
      (nav_data || []).reject! do |nav|
        children = (nav['children'] || [])
        prune_childless_parents(children)
        nav['generated'] && children.empty?
      end
    end
  end
end
