# frozen_string_literal: true

source "https://rubygems.org"

# Jekyll core and theme
gem "jekyll", "~> 4.3.2"
gem "jekyll-theme-chirpy", "~> 6.5", ">= 6.5.5"

# Jekyll plugins required for Chirpy theme
gem "jekyll-paginate", "~> 1.1"
gem "jekyll-redirect-from", "~> 0.16"
gem "jekyll-seo-tag", "~> 2.8"
gem "jekyll-archives", "~> 2.2"
gem "jekyll-sitemap", "~> 1.4"
gem "jekyll-feed", "~> 0.17"

# Testing and development
gem "html-proofer", "~> 5.0", group: :test

# Performance and caching
gem "jekyll-include-cache", "~> 0.2"

# Windows/JRuby platform support
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

# Additional gems for development
group :jekyll_plugins do
  gem "jekyll-compose", "~> 0.12.0"
end