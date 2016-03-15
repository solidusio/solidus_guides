module GuidesStyle18F
  class NamespaceFlattener
    def self.flatten_url_namespace(site, docs)
      flatten_urls(docs) if site.config['flat_namespace']
    end

    def self.flatten_urls(docs)
      flat_to_orig = {}
      docs.each { |page| flatten_page_urls(page, flat_to_orig) }
      check_for_collisions(flat_to_orig)
    end

    def self.flatten_page_urls(page, flat_to_orig)
      orig_url = page.permalink || page.url
      flattened_url = flat_url(orig_url)
      (flat_to_orig[flattened_url] ||= []) << orig_url
      page.data['permalink'] = flattened_url
      (page.data['breadcrumbs'] || []).each do |crumb|
        crumb['url'] = flat_url(crumb['url'])
      end
    end

    def self.flat_url(url)
      url == '/' ? url : "/#{url.split('/')[1..-1].last}/"
    end

    def self.check_for_collisions(flat_to_orig)
      collisions = flat_to_orig.map do |flattened, orig|
        [flattened, orig] if orig.size != 1
      end.compact

      return if collisions.empty?

      messages = collisions.map { |flat, orig| "#{flat}: #{orig.join(', ')}" }
      fail(StandardError, "collisions in flattened namespace between\n  " +
        messages.join("\n  "))
    end
  end
end
