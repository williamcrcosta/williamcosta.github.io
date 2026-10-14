# frozen_string_literal: true

Jekyll::Hooks.register :site, :post_read do |site|
  site.pages.reject! do |page|
    [page.path, page.relative_path].include?("assets/feed.xml")
  end
end
