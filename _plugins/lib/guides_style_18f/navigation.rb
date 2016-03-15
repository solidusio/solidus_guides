# @author Mike Bland (michael.bland@gsa.gov)

require_relative './generated_nodes'

require 'jekyll'
require 'safe_yaml'

module GuidesStyle18F
  module FrontMatter
    EXTNAMES = %w(.md .html)

    def self.load(basedir)
      # init_file_to_front_matter_map is initializing the map with a nil value
      # for every file that _should_ contain front matter as far as the
      # navigation menu is concerned. Any nil values that remain after merging
      # with the site_file_to_front_matter map will result in a validation
      # error.
      init_file_to_front_matter_map(basedir).merge(
        site_file_to_front_matter(init_site(basedir)))
    end

    def self.validate_with_message_upon_error(front_matter)
      files_with_errors = validate front_matter
      return if files_with_errors.empty?
      message = ['The following files have errors in their front matter:']
      files_with_errors.each do |file, errors|
        message << "  #{file}:"
        message.concat errors.map { |error| "    #{error}" }
      end
      message.join "\n" unless message.size == 1
    end

    def self.validate(front_matter)
      front_matter.map do |file, data|
        next [file, ['no front matter defined']] if data.nil?
        errors = missing_property_errors(data) + permalink_errors(data)
        [file, errors] unless errors.empty?
      end.compact.to_h
    end

    private

    def self.init_site(basedir)
      Dir.chdir(basedir) do
        config = SafeYAML.load_file('_config.yml', safe: true)
        adjust_config_paths(basedir, config)
        site = Jekyll::Site.new(Jekyll.configuration(config))
        site.reset
        site.read
        site
      end
    end

    def self.adjust_config_paths(basedir, config)
      source = config['source']
      config['source'] = source.nil? ? basedir : File.join(basedir, source)
      destination = config['destination']
      destination = '_site' if destination.nil?
      config['destination'] = File.join(basedir, destination)
    end

    def self.site_file_to_front_matter(site)
      site_pages(site).map do |page|
        [page.relative_path,  page.data]
      end.to_h
    end

    # We're supporting two possible configurations:
    #
    # - a `pages/` directory in which documents appear as part of the regular
    #   site.pages collection; we have to filter by page.relative_path, and we
    #   do not assign a permalink so that validation (in a later step) will
    #   ensure that each page has a permalink assigned
    #
    # - an actual `pages` collection, stored in a `_pages` directory; no
    #   filtering is necessary, and we can reliably set the permalink to
    #   page.url as a default
    def self.site_pages(site)
      pages = site.collections['pages']
      if pages.nil?
        site.pages.select do |page|
          page.relative_path.start_with?('/pages') || page.url == '/'
        end
      else
        pages.docs.each { |page| page.data['permalink'] ||= page.url }
      end
    end

    def self.init_file_to_front_matter_map(basedir)
      file_to_front_matter = {}
      Dir.chdir(basedir) do
        pages_dir = Dir.exist?('_pages') ? '_pages' : 'pages'
        Dir[File.join(pages_dir, '**', '*')].each do |file_name|
          extname = File.extname(file_name)
          next unless File.file?(file_name) && EXTNAMES.include?(extname)
          file_to_front_matter[file_name] = nil
        end
      end
      file_to_front_matter
    end

    def self.missing_property_errors(data)
      properties = %w(title permalink)
      properties.map { |p| "no `#{p}:` property" if data[p].nil? }.compact
    end

    def self.permalink_errors(data)
      pl = data['permalink']
      return [] if pl.nil?
      errors = []
      errors << "`permalink:` does not begin with '/'" unless pl.start_with? '/'
      errors << "`permalink:` does not end with '/'" unless pl.end_with? '/'
      errors
    end
  end

  # Automatically updates the `navigation:` field in _config.yml.
  #
  # Does this by parsing the front matter from files in `pages/`. Preserves the
  # existing order of items in `navigation:`, but new items may need to be
  # reordered manually.
  def self.update_navigation_configuration(basedir)
    config_path = File.join basedir, '_config.yml'
    config_data = SafeYAML.load_file config_path, safe: true
    return unless config_data
    nav_data = config_data['navigation'] || []
    NavigationMenu.update_navigation_data(nav_data, basedir, config_data)
    NavigationMenuWriter.write_navigation_data_to_config_file(
      config_path, nav_data)
  end

  module NavigationMenu
    def self.update_navigation_data(nav_data, basedir, config_data)
      original = map_nav_items_by_url('/', nav_data).to_h
      updated = updated_nav_data(basedir)
      remove_stale_nav_entries(nav_data, original, updated)
      updated.map { |url, nav| apply_nav_update(url, nav, nav_data, original) }
      if config_data['generate_nodes']
        GeneratedNodes.create_homes_for_orphans(original, nav_data)
      else
        check_for_orphaned_items(nav_data)
      end
    end

    def self.map_nav_items_by_url(parent_url, nav_data)
      nav_data.flat_map do |nav|
        url = File.join('', parent_url, nav['url'] || '')
        [[url, nav]].concat(map_nav_items_by_url(url, nav['children'] || []))
      end
    end

    def self.updated_nav_data(basedir)
      front_matter = FrontMatter.load basedir
      errors = FrontMatter.validate_with_message_upon_error front_matter
      abort errors + "\n_config.yml not updated" if errors
      front_matter.values.sort_by { |fm| fm['permalink'] }
        .map { |fm| [fm['permalink'], page_nav(fm)] }.to_h
    end

    def self.page_nav(front_matter)
      url_components = front_matter['permalink'].split('/')[1..-1]
      result = {
        'text' => front_matter['navtitle'] || front_matter['title'],
        'url' => "#{url_components.nil? ? '' : url_components.last}/",
        'internal' => true,
      }
      # Delete the root URL so we don't have an empty `url:` property laying
      # around.
      result.delete 'url' if result['url'] == '/'
      result
    end

    def self.remove_stale_nav_entries(nav_data, original, updated)
      # Remove old entries whose pages have been deleted
      original.each do |url, nav|
        if !updated.member?(url) && nav['internal'] && !nav['generated']
          nav['delete'] = true
        end
      end
      original.delete_if { |_url, nav| nav['delete'] }
      nav_data.delete_if { |nav| nav['delete'] }
      nav_data.each { |nav| remove_stale_children(nav) }
    end

    def self.remove_stale_children(parent)
      children = (parent['children'] || [])
      children.delete_if { |nav| nav['delete'] }
      parent.delete 'children' if children.empty?
      children.each { |child| remove_stale_children(child) }
    end

    def self.apply_nav_update(url, nav, nav_data, original)
      orig = original[url]
      if orig.nil?
        apply_new_nav_item(url, nav, nav_data, original)
      else
        orig['text'] = nav['text']
        orig.delete('generated')
      end
    end

    def self.apply_new_nav_item(url, nav, nav_data, original)
      parent_url = File.dirname(url || '/')
      parent = original["#{parent_url}/"]
      if parent_url == '/'
        nav_data << (original[url] = nav)
      elsif parent.nil?
        nav_data << nav.merge(orphan_url: url)
      else
        (parent['children'] ||= []) << nav
      end
    end

    def self.check_for_orphaned_items(nav_data)
      orphan_urls = nav_data.map { |nav| nav[:orphan_url] }.compact
      unless orphan_urls.empty?
        fail(StandardError, "Parent pages missing for the following:\n  " +
          orphan_urls.join("\n  "))
      end
    end
  end

  class NavigationMenuWriter
    def self.write_navigation_data_to_config_file(config_path, nav_data)
      lines = []
      in_navigation = false
      open(config_path).each_line do |line|
        in_navigation = process_line line, lines, nav_data, in_navigation
      end
      File.write config_path, lines.join
    end

    def self.process_line(line, lines, nav_data, in_navigation = false)
      if !in_navigation && line.start_with?('navigation:')
        lines << line << format_navigation_section(nav_data)
        in_navigation = true
      elsif in_navigation
        in_navigation = line.start_with?(' ') || line.start_with?('-')
        lines << line unless in_navigation
      else
        lines << line
      end
      in_navigation
    end

    YAML_PREFIX = "---\n"

    def self.format_navigation_section(nav_data)
      nav_data.empty? ? '' : nav_data.to_yaml[YAML_PREFIX.size..-1]
    end
  end
end
