require 'net/ftp'
require "csv"
module SpreeGoogleMerchant
  class FeedBuilder
    include Spree::Core::Engine.routes.url_helpers
    include Rails.application.routes.url_helpers

#  def self.default_url_options
#   ActionMailer::Base.default_url_options
# end

    attr_reader :store, :domain, :title

    def self.generate_and_transfer
      self.builders.each do |builder|
        builder.generate_and_transfer_store
      end
    end

    def self.generate
      self.builders.each do |builder|
        builder.generate_store
      end
    end

    def self.transfer partner = :google
      self.builders.each do |builder|
        builder.transfer_xml partner
      end
    end

    def self.builders
      if defined?(Spree::Store)
        Spree::Store.all.map { |store| self.new(:store => store) }
      else
        [self.new]
      end
    end

    def initialize(opts = {})
      raise "Please pass a public address as the second argument, or configure :public_path in Spree::GoogleMerchant::Config" unless opts[:store].present? or (opts[:path].present? or Spree::GoogleMerchant::Config[:public_domain])

      @store = opts[:store] if opts[:store].present?
      @title = @store ? @store.name : Spree::GoogleMerchant::Config[:title]

      @domain = @store ? @store.domains.match(/[\w\.]+/).to_s : opts[:path]
      @domain ||= Spree::GoogleMerchant::Config[:public_domain]
    end

#    def ads
#      Spree::ProductAd.active.includes([:channel, :variant => [:product]]).where("spree_product_ad_channels.channel_type = 'google_shopping'")
#    end

    def generate_store
      delete_xml_if_exists

      File.open(path, 'w') do |file|
        generate_xml file
      end

      FileUtils.cp path, path(:linkshare) if Spree::GoogleMerchant::Config[:linkshare_ftp_filename]
    end

    def generate_and_transfer_store
      delete_xml_if_exists

      File.open(path, 'w') do |file|
        generate_xml file
      end

      transfer_xml
      cleanup_xml
    end

    def path partner = :google
      if partner == :linkshare
        "#{::Rails.root}/tmp/#{Spree::GoogleMerchant::Config[:linkshare_ftp_filename]}"
      else
        "#{::Rails.root}/public/#{self.filename}"
        # "/home/hosting/scoutandnimble/shared/public/#{self.filename}"

      end

    end

    def filename
      "google_shopping.xml"
    end

    def delete_xml_if_exists
      File.delete(path) if File.exists?(path)
    end

    def validate_record(product)
      # return false if @assets.select { |s| s.viewable_id == product.master.id }.length == 0 rescue true
      return false if product.google_merchant_title.nil?
      #return false if product.google_merchant_product_category.nil?
      #return false if product.google_merchant_availability.nil?
      return false if product.google_merchant_price.nil? || product.google_merchant_price.to_i == 0
      #return false if product.google_merchant_brand.nil?
      #return false if product.google_merchant_gtin.nil?
      #return false if product.google_merchant_mpn.nil?
      #return false unless validate_upc(product.upc)

      #unless product.google_merchant_sale_price.nil?
      #  return false if product.google_merchant_sale_price_effective.nil?
      #end

      true
    end

    def generate_xml output
      xml = Builder::XmlMarkup.new(:target => output)
      xml.instruct!

      xml.rss(:version => '2.0', :"xmlns:g" => "http://base.google.com/ns/1.0") do
        xml.channel do
          build_meta(xml)
          # @assets = Spree::Asset.all
          Spree::Product.where("deleted_at IS NULL OR deleted_at >= ?", Time.zone.now).includes(:taxons, :product_properties, :properties, :option_types, variants_including_master: [:default_price, :prices, :images, option_values: :option_type]).find_each(batch_size: 400) do |product|
            # Spree::Product.includes(:taxons, :product_properties, :properties, :option_types, variants_including_master: [:default_price, :prices, :images, option_values: :option_type]).limit(1000).each do |product|
            next unless product && validate_record(product) # product.variants &&
            build_feed_item(xml, product)
          end
        end
      end
    end

    def transfer_xml partner = :google
      if partner == :google
        raise "Please configure your Google Merchant :ftp_username and :ftp_password by configuring Spree::GoogleMerchant::Config" unless Spree::GoogleMerchant::Config[:ftp_username] and Spree::GoogleMerchant::Config[:ftp_password]
        ftp_domain = 'uploads.google.com'
        username = Spree::GoogleMerchant::Config[:ftp_username]
        password = Spree::GoogleMerchant::Config[:ftp_password]
        filename = self.filename
      elsif partner == :linkshare
        raise "Please configure your Linkshare :linkshare_ftp_username and :linkshare_ftp_password by configuring Spree::GoogleMerchant::Config" unless Spree::GoogleMerchant::Config[:linkshare_ftp_username] and Spree::GoogleMerchant::Config[:linkshare_ftp_password]
        ftp_domain = 'ftp.popshops.com'
        username = Spree::GoogleMerchant::Config[:linkshare_ftp_username]
        password = Spree::GoogleMerchant::Config[:linkshare_ftp_password]
        filename = Spree::GoogleMerchant::Config[:linkshare_ftp_filename]
      end

      ftp = Net::FTP.new(ftp_domain)
      ftp.passive = true
      ftp.login(username, password)
      ftp.put(path, filename)
      ftp.quit
    end

    def cleanup_xml
      File.delete(path)
    end

    def build_feed_item(xml, product)
      (product.variants.present? ? product.variants : product.variants_including_master).each do |variant|
        xml.item do
          xml.tag!('link', "https://#{Spree::Config.site_url.gsub(/\/$/, '')}/products/#{product.slug}")
          build_images(xml, product)
          #xml.tag!('link', products_url(product.slug, host: Spree::Config.site_url.gsub(/\/$/,''), protocol: 'https'))

          GOOGLE_MERCHANT_ATTR_MAP.each do |k, v|
            k == 'g:price' ? value = variant.send("google_merchant_#{v}") : value = product.send("google_merchant_#{v}")
            xml.tag!(k, value.to_s) if value.present?
          end
          if variant.product.sale_display and variant.sale_price.present?
            xml.tag!('g:sale_price', variant.google_merchant_sale_price)
            if variant.start_sale_date and variant.end_sale_date
              xml.tag!('g:sale_price_effective_data', "#{variant.start_sale_date.strftime('%Y-%m-%dT%I-%M%z')}/#{variant.end_sale_date.strftime('%Y-%m-%dT%I-%M%z')}")
            end
          end
          xml.tag!('g:availability', 'in stock')
          xml.tag!('g:id', variant.id)
          # xml.tag!('g:mpn', variant.id)
          xml.tag!('g:identifier_exists', 'false')#variant.sku.present? ? 'yes' : 'no')
          build_product_type(xml, product)
          # build_brand(xml, product)
          build_shipping(xml, product)
          # build_adwords_labels(xml, product)
          build_custom_labels(xml, product, variant)
        end
      end
    end

    def build_brand(xml, product)
      value = product.send("google_merchant_brand") || "Scout & Nimble"
      xml.tag!('g:brand', value)
    end

    def build_product_type(xml, product)
      xml.tag!('product_type', product.google_merchant_product_type)
    end

    def build_images(xml, product)
      main_image, *more_images = product.master.images

      return unless main_image
      xml.tag!('g:image_link', image_url(main_image).sub(/\?.*$/, '').sub(/^\/\//, 'http://'))

      more_images.each do |image|
        xml.tag!('g:additional_image_link', image_url(image).sub(/\?.*$/, '').sub(/^\/\//, 'http://'))
      end
    end

    def image_url image
      base_url = image.attachment.url(:product)
      #base_url = "#{domain}/#{base_url}" unless Spree::Config[:use_s3]

      base_url
    end

#    def validate_upc(upc)
#      return false if upc.nil?
#      digits = upc.split('')
#      len = upc.length
#      return false unless [8,12,13,14].include? len
#      check = 0
#      digits.reverse.drop(1).reverse.each_with_index do |i,index|
#        check += (index.to_i % 2 == len % 2 ? i.to_i * 3 : i.to_i )
#      end
#      ((10 - check % 10) % 10) == digits.last.to_i
#    end

# <g:shipping>
    def build_shipping(xml, product)
      xml.tag!('g:shipping') do
        xml.tag!('g:price', "0.00 USD")
      end
    end

# <g:adwords_labels>
    def build_adwords_labels(xml, product)
      labels = []

      list = [:category, :group, :type, :theme, :keyword, :color, :shape, :brand, :size, :material, :for, :agegroup]
      list.each do |prop|
        if labels.length < 10 then
          value = product.google_merchant_property(prop)
          labels << value if value.present?
        end
      end

      labels.slice(0..9).each do |l|
        xml.tag!('g:adwords_labels', l)
      end
    end

    def build_custom_labels(xml, product, variant)
      # Set availability
      xml.tag!('g:custom_label_0', (product.shipping_category.present? and product.shipping_category.name == "Freight Shipping") ? 'freight' : 'small parcel')
      xml.tag!('g:custom_label_1', 'sale') if product.sale_taxon?
      xml.tag!('g:custom_label_2', product.brand.present? ? product.brand.name : "Scout & Nimble")
      xml.tag!('g:custom_label_3', define_price_tier(variant)) if variant.present?
      xml.tag!('g:custom_label_4', define_backorderable_custom(product, variant))
      # xml.tag!('g:custom_label_0', product.google_merchant_size_type)
      # xml.tag!('g:custom_label_1', product.google_merchant_taxon)
    end

    def define_backorderable_custom(product, variant)
      value = ""
      if variant.present?
        if variant.stock_items.sum(&:count_on_hand) > 0
          value = "in stock"
        elsif variant.backorderable
          value = "preorder"
        else
          value = "out of stock"
        end
      else
        if product.master.stock_items.sum(&:count_on_hand) > 0
          value = "in stock"
        elsif product.master.backorderable
          value = "preorder"
        else
          value = "out of stock"
        end
      end
      value
    end

    def define_price_tier(variant)
      return unless variant.present?
      case variant.price
      when 0..300
        "tier 1"
      when 300..600
        "tier 2"
      when 600..900
        "tier 3"
      else
        "tier 4"
      end
    end

    def build_meta(xml)
      xml.title @title
      xml.link @domain
    end

    def csv_field_builder
      file_name = 'google_shopping.csv'
      # file_path = "#{::Rails.root}/public/#{file_name}"
      file_path = "/home/hosting/scoutandnimble/shared/public/#{file_name}"
      if !Rails.env.development? and File.exists?(file_path)
        time = Time.zone.now.strftime('%m_%d_%Y_%I_%M')
        old_feed = "/home/hosting/scoutandnimble/shared/feeds/google_shopping#{time}.csv"
        FileUtils.mv('/home/hosting/scoutandnimble/shared/public/google_shopping.csv', old_feed)
      end
      CSV.open(file_path, 'wb', col_sep: "\t") do |csv|
        csv << %w(id title description link image_link additional_image_link availability price condition sale_price sale_price_effetive_date google_product_category identifier_exists product_type custom_label_0 custom_label_1 custom_label_2 custom_label_3 brand)
        Spree::Product.where('deleted_at IS NULL OR deleted_at >= ?', Time.zone.now).includes(:taxons, :product_properties, :properties, :option_types, variants_including_master: [:default_price, :prices, :images, option_values: :option_type]).find_each(batch_size: 400) do |product|
          next unless product && validate_record(product) && product.master.images.present?
          (product.variants.present? ? product.variants : product.variants_including_master).each do |variant|
            csv << csv_row_google_feed(variant, product)
          end
        end

      end
      Resque.enqueue DeleteOldestFeed
    end

    def csv_row_google_feed(variant, product)
      images = product.master.csv_google_merchant_images
      [variant.id,
       product.send('google_merchant_title'),
       product.send('google_merchant_description'),
       product.send('product_link'),
       images[0],
       images[1],
       define_backorderable_custom(product, variant),
       variant.send('google_merchant_price'),
       product.send('google_merchant_condition'),
       variant.send('google_merchant_sale_price'),
       variant.send('google_merchant_sale_time_range'),
       product.send('google_merchant_product_category'),
       'false',
       product.google_merchant_product_type,
       product.send('google_shipping'),
       product.send('sale_taxon'),
       product.send('brand_name'),
       define_price_tier(variant),
       define_backorderable_custom(product, variant),
       product.send('brand_name')]
    end
  end
end
