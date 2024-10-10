# frozen_string_literal: true

source "https://rubygems.org"

# Adicione o Jekyll
gem "jekyll", "~> 4.3.4"  # Ajuste a versão conforme necessário
#gem "github-pages", "~> 228", group: :jekyll_plugins
# gem "minima", "~> 2.5"  # Se você quiser usar o tema minima, descomente esta linha

# Adicione o jekyll-feed
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-theme-chirpy", "~> 6.5.5"  # Mantenha o tema Chirpy
end

group :test do
  gem "html-proofer", "~> 3.19.4"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", platforms: [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", platforms: [:jruby]

# Lock jekyll-sass-converter to 2.x on Linux-musl
if RUBY_PLATFORM =~ /linux-musl/
  gem "jekyll-sass-converter", "~> 2.0"
end
