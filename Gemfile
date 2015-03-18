source 'http://rubygems.org'

gemspec

spree_branch = '2-1-stable'

gem 'spree', github: 'spree/spree', branch: spree_branch
gem 'spree_hub', github: 'reformation/hub_gem', branch: 'reformation/' + spree_branch
gem 'spree_static_content', github: 'spree/spree_static_content', branch: spree_branch

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'mocha'
end
