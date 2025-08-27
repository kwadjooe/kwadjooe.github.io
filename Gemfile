# frozen_string_literal: true

source "https://rubygems.org"

# GitHub Pages gem includes Jekyll and compatible plugin versions
gem "github-pages", group: :jekyll_plugins

# Remote theme support
gem "jekyll-remote-theme"

# Testing and development
gem "html-proofer", "~> 5.0", group: :test

# Windows/JRuby platform support
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]