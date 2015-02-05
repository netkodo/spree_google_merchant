# -*- encoding: utf-8 -*-
# stub: spree_google_merchant 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "spree_google_merchant"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Steph Skardal", "Ryan Siddle", "Roman Smirnov", "Denis Ivanov", "Tyler Fitts"]
  s.date = "2015-02-04"
  s.description = "Provide rake task to generate XML for Google Merchant."
  s.files = [".gitignore", "Gemfile", "Gemfile.lock", "README.markdown", "README.md", "Rakefile", "Versionfile", "app/controllers/spree/admin/google_merchant_settings_controller.rb", "app/controllers/spree/admin/product_ad_channels_controller.rb", "app/controllers/spree/admin/product_ads_controller.rb", "app/helpers/spree/admin/google_merchant_helper.rb", "app/models/spree/cpc_manager.rb", "app/models/spree/google_merchant_configuration.rb", "app/models/spree/order_decorator.rb", "app/models/spree/product_decorator.rb", "app/models/spree/shipment_decorator.rb", "app/models/spree/variant_decorator.rb", "app/overrides/decorate_admin_config_index.rb", "app/overrides/insert_advertising_into_admin_header.rb", "app/views/spree/admin/advertising/show.html.erb", "app/views/spree/admin/google_merchant_settings/edit.html.erb", "app/views/spree/admin/google_merchant_settings/show.html.erb", "app/views/spree/admin/product_ad_channels/_form.html.erb", "app/views/spree/admin/product_ad_channels/edit.html.erb", "app/views/spree/admin/product_ad_channels/index.html.erb", "app/views/spree/admin/product_ad_channels/show.html.erb", "app/views/spree/admin/product_ads/edit.html.erb", "app/views/spree/admin/product_ads/index.html.erb", "app/views/spree/admin/product_ads/show.html.erb", "config/locales/en.yml", "config/routes.rb", "lib/spree_google_merchant.rb", "lib/spree_google_merchant/amazon_feed_builder.rb", "lib/spree_google_merchant/bing_feed_builder.rb", "lib/spree_google_merchant/cancellation_feed_builder.rb", "lib/spree_google_merchant/ebay_feed_builder.rb", "lib/spree_google_merchant/engine.rb", "lib/spree_google_merchant/feed_builder.rb", "lib/spree_google_merchant/shipping_feed_builder.rb", "lib/tasks/spree_google_merchant_extension_tasks.rake", "script/rails", "spec/factories.rb", "spec/lib/spree_google_merchant/feed_builder_spec.rb", "spec/models/spree/product_spec.rb", "spec/spec_helper.rb", "spree_google_merchant.gemspec"]
  s.homepage = "http://github.com/tfitts/spree_google_merchant"
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.requirements = ["none"]
  s.rubygems_version = "2.2.2"
  s.summary = "Google Merchant for Spree"
  s.test_files = ["spec/factories.rb", "spec/lib/spree_google_merchant/feed_builder_spec.rb", "spec/models/spree/product_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree>, ["~> 2.0"])
      s.add_runtime_dependency(%q<net-sftp>, ["= 2.1.2"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.7"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<factory_girl>, ["~> 2.6"])
    else
      s.add_dependency(%q<spree>, ["~> 2.0"])
      s.add_dependency(%q<net-sftp>, ["= 2.1.2"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.7"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<factory_girl>, ["~> 2.6"])
    end
  else
    s.add_dependency(%q<spree>, ["~> 2.0"])
    s.add_dependency(%q<net-sftp>, ["= 2.1.2"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.7"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<factory_girl>, ["~> 2.6"])
  end
end
