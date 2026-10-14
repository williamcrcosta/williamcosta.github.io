#!/usr/bin/env ruby
#
# Check for changed posts

Jekyll::Hooks.register :posts, :post_init do |post|

  # Get the commit dates for the post, including file renames
  lastmod_dates = `git log --follow --pretty="%ad" --date=iso -- "#{post.path}"`.lines

  # If the post has more than one commit, update the last modified date
  if lastmod_dates.size > 1
    post.data['last_modified_at'] = lastmod_dates.first.strip
  end

end
