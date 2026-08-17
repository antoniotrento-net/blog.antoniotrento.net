source "https://rubygems.org"

# Stessa versione del sito principale (dev locale via Docker jekyll/jekyll:4).
# Nota: GitHub Pages "classic" builda con la propria toolchain (Jekyll 3.9 +
# github-pages); il sito è scritto in modo compatibile con entrambe.
gem "jekyll", "~> 4.3.4"
gem "minima", "~> 2.5"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-sitemap"
end

# Windows / JRuby: zoneinfo
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1", :platforms => [:mingw, :x64_mingw, :mswin]
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]
