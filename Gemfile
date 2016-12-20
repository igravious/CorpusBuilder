source 'https://rubygems.org'

# http://www.justinweiss.com/articles/what-are-the-differences-between-irb/
#
# irb
# bin/bundle exec irb
# bin/bundle console
# bin/rails console

# http://www.justinweiss.com/articles/how-does-rails-handle-gems/
#
# gems are in default group by default

# Bundle edge Rails instead with: gem 'rails', github: 'rails/rails'
gem 'rails'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery (2.2.0) as the JavaScript library, and make unobtrusive js jquery_ujs
gem 'jquery-rails' 

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use Cocoon to handle nested forms
gem 'cocoon'

# Use Nokogiri for snarfing XML
gem 'nokogiri'

# Party hard
gem 'httparty'

group :task do
	# Snarf hard
	gem 'watir-webdriver'
	gem 'headless'

	# Ruby RDF goodness
	gem 'json-ld'
	gem 'rdf-turtle'
	gem 'rdf-raptor'
	# gem 'sparql'
	gem 'sparql-client'

	# ElasticSearch
	gem 'elasticsearch'

	# WordNet
	gem 'rwordnet'

	# Ruby interface to Cayley
	gem 'cayley', :git => 'https://github.com/igravious/cayley-ruby.git'

	# Guess what
	gem 'rzotero'

	# Ruby interface to ImageMagick
	gem 'rmagick'

	# Play with the _other_ HTTP client library
	gem 'faraday'

	# Pretty colours
	gem 'rouge'

	# Cache API requests
	gem 'api_cache'

	# Key/Value store interface (think Rack for K/V stores)
	gem 'moneta'
	# High performance pure Ruby client for accessing memcached server
	gem 'dalli'
end

# Use debugger
# gem 'byebug', group: [:development, :test]
# gem 'ruby-debug-passenger', group: [:development, :test]

group :development, :test do
 # The most awesome Pry
 gem 'pry'
 
 # Call 'byebug' anywhere in the code to stop execution and get a debugger console
 # gem 'byebug'
 
 # Access an IRB console on exception pages or by using <%= console %> in views
 # gem 'web-console', '~> 2.0'

 # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
 # gem 'spring'
end
