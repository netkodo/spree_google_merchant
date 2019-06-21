module Spree
  Product.class_eval do
    scope :google_merchant_scope, includes(:taxons, {:master => :images}).includes(:product_properties)
#    scope :amazon_ads, joins([{:product_properties => :property}, {:master => :stock_items}]).where("not (spree_properties.name = 'brand' and spree_product_properties.value = 'Loftus') and spree_stock_items.count_on_hand <> 0").where("imagesize >= 500").includes(:taxons, {:master => [:images, :stock_items]}).includes(:product_properties).group(:id)
#    scope :ebay_ads, joins([{:product_properties => :property}, {:master => :stock_items}]).where("spree_stock_items.count_on_hand <> 0").where("imagesize >= 300").includes(:taxons, {:master => [:images, :stock_items]}).includes(:product_properties).group(:id)

    def first_property(property_name)
      value = self.property(property_name)
      if value.kind_of?(Array) && value.length > 0
        value = value[0]
      end
      value
    end

    def google_merchant_description
      return nil if self.description.blank?
      self.description.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, "")
    end

    def google_merchant_title
      self.name.split(/\s/).map {|w| w.capitalize}.join(' ')
    end

    # <g:google_product_category> Apparel & Accessories > Clothing > Dresses (From Google Taxon Map)
    def google_merchant_product_category
      self.google_merchant_property(:gm_product_category) || Spree::GoogleMerchant::Config[:product_category]
    end

    def google_merchant_product_type
      return unless taxons.any?
      taxons[0].self_and_ancestors.map(&:name).join(" > ")
    end

    # <g:condition> new | used | refurbished
    def google_merchant_condition
      'new'
    end

    def sale_taxon?
      taxons.where(permalink: 'department/sale').present?
    end

    # <g:availability> in stock | available for order | out of stock | preorder
#    def google_merchant_availability
#      self.master.stock_items.sum(:count_on_hand) > 0 ? 'in stock' : 'out of stock'
#    end
#
#    def google_merchant_quantity
#      self.master.stock_items.sum(:count_on_hand)
#    end

    def google_merchant_image_link
      self.max_image_url
    end

   def google_merchant_brand
     self.google_merchant_property(:brand)
   end

    # <g:price> 15.00 USD
    def google_merchant_price
      return if self.price.nil?
      format("%.2f %s", self.price, self.currency).to_s
    end

    # <g:sale_price> 15.00 USD
    def google_merchant_sale_price
      unless self.google_merchant_property(:gm_sale_price).nil?
        format("%.2f %s", self.google_merchant_property(:gm_sale_price), self.currency).to_s
      end
    end

    # <g:sale_price_effective_date> 2011-03-01T13:00-0800/2011-03-11T15:30-0800
    def google_merchant_sale_price_effective_date
      unless self.google_merchant_property(:gm_sale_price_effective).nil?
        return # TODO
      end
    end

    def google_merchant_item_group_id
      self.sku
    end

    # <g:gtin> 8-, 12-, or 13-digit number (UPC, EAN, JAN, or ISBN)
    def google_merchant_gtin
      self.master.gtin rescue self.upc
    end

    # <g:mpn> Alphanumeric characters
    def google_merchant_mpn
      self.sku.gsub(/[^0-9a-z ]/i, '')
    end

    # <g:gender> Male, Female, Unisex
    def google_merchant_gender
      'female'
    end

    # <g:age_group> Adult, Kids
    def google_merchant_age_group
      'adult'
    end

    # <g:color>
    def google_merchant_color
      self.google_merchant_property(:color).capitalize if self.google_merchant_property(:color)
    end

    # <g:size>
#    def google_merchant_size
#      self.google_merchant_property(:size)
#    end

    def google_merchant_size_type
      self.google_merchant_property(:size_type)
    end

    # <g:adwords_grouping> single text value
    def google_merchant_adwords_group
      self.google_merchant_property(:gm_adwords_group)
    end

    # <g:shipping_weight> # lb, oz, g, kg.
    def google_merchant_shipping_weight
      return unless self.weight.present?
      weight_units = 'oz'       # need a configuration parameter here
      format("%s %s", self.weight, weight_units)
    end

    # <g:adult> TRUE | FALSE
    def google_merchant_adult
      self.google_merchant_property(:gm_adult) unless self.google_merchant_property(:gm_adult).nil?
    end

    # reduce queries
    def google_merchant_property prop
      property_id = self.properties.select{|p| p.name == prop.to_s }[0].try(:id)
      self.product_properties.select{|pp| pp.property_id == property_id }.first.try('value')
    end

    ## Amazon Listing Methods
    def amazon_category
      self.google_merchant_property(:category)
    end

    def amazon_title
      self.name
    end

    def amazon_link
      self.url
    end

    def amazon_sku
      self.sku
    end

    def amazon_price
      self.price.to_s
    end

    def amazon_image
      self.max_image_url
    end

    def amazon_upc
      self.upc
    end

    def amazon_brand
      self.google_merchant_property(:brand)
    end

    def amazon_recommended_browse_node
      # case self.property(:group)
      # when "Costumes"
      #   case self.property(:gender)
      #   when "Boys"

      #   when "Girls"

      #   when "Men"

      #   when "Women"
          
      # if self.property(:group) == "Costumes"
      #   if self.property(:gender) == "Boys"
      #     727631011
      #   elsif self.property(:gender) == "Girls"
      #     727632011
      #   elsif self.property(:gender) == ""
          
      # elsif 

      # elsif 

      # elsif 
      ""        
    end

    def amazon_department
      self.google_merchant_property(:category)
    end

    def amazon_description
      self.description
    end

    def amazon_manufacturer
      ""
    end

    def amazon_mfr_part_number
      ""
    end

    def amazon_shipping_cost
      if !master.fulfillment_cost.nil? && master.fulfillment_cost > 0
        master.fulfillment_cost.to_f
      else
        ""
      end
    end

    def amazon_item_package_quantity
      count = self.google_merchant_property(:count)
      if count.kind_of?(Array)
        count = count[0]
      end
      if count.nil?
        1
      else
        Integer(count)
      end
    end

    def amazon_size
      self.google_merchant_property(:size)
    end

    def amazon_color
      self.google_merchant_property(:color)
    end

    def amazon_gender
      self.google_merchant_property(:gender)
    end

    def amazon_material
      self.google_merchant_property(:material)
    end

    def amazon_occasion
      if self.taxons.present? && self.taxons.first.present? && self.taxons.first.name.present?
        self.taxons.first.name
      else
        ""
      end
    end

    def amazon_sku_bid
      # if self.master.stock_items.first.count_on_hand <= 0
      #   0.0
      # else
      #   ""
      # end
      ""
    end

    def ebay_unique_merchant_sku
      self.id
    end

    def ebay_product_name
      self.name
    end

    def ebay_product_url
      "#{self.url}?utm_source=ebaycn&utm_medium=cpc&utm_campaign=ebay-product-ads"
    end

    def ebay_image_url
      self.max_image_url
    end

    def ebay_current_price
      self.price.to_s
    end

    def ebay_stock_availability
      self.master.stock_items.sum(:count_on_hand) > 0 ? 'In Stock' : 'Out of Stock'
    end

    def ebay_condition
      "New"
    end

    def ebay_upc
      self.upc
    end

    def ebay_shipping_rate
      self.master.fulfillment_cost
    end

    def ebay_original_price
      self.msrp
    end

    def ebay_brand
      self.google_merchant_property(:brand)
    end

    def ebay_product_description
      self.description
    end

    def ebay_product_type
      type = ""
      if self.google_merchant_property(:type)
        type = self.google_merchant_property(:type)
      elsif self.google_merchant_property(:group)
        type = self.google_merchant_property(:group)
      elsif self.google_merchant_property(:category)
        type = self.google_merchant_property(:category)
      end
      if type.kind_of?(Array)
        type = type[0].to_s
      end
      type
    end

    def ebay_category
      types = []
      if self.google_merchant_property(:category)
        types << self.google_merchant_property(:category)
      end
      if self.google_merchant_property(:group)
        types << self.google_merchant_property(:group)
      end
      if self.google_merchant_property(:type)
        types << self.google_merchant_property(:type)
      end
      types.join(' > ')
    end

    def bing_mpid
      self.id
    end

    def bing_title
      self.name
    end

    def bing_brand
      self.google_merchant_property(:brand)
    end

    def bing_producturl
      "#{self.url}?utm_source=bing&utm_medium=cpc&utm_campaign=bing-product-ads"
    end

    def bing_price
      self.price.to_s
    end

    def bing_description
      self.description
    end

    def bing_imageurl
      ebay_image_url
    end

    def bing_upc
      self.upc
    end

    def bing_sku
      self.sku
    end

    def bing_shipping
      ebay_shipping_rate
    end

    def bing_condition
      "New"
    end

    def bing_producttype
      ebay_category
    end

    def bing_availability
      ebay_stock_availability
    end

    def google_shipping
      (self.shipping_category.present? and self.shipping_category.name == 'Freight Shipping') ? 'freight' : 'small parcel'
    end

    def brand_name
      self.supplier.present? ? self.supplier.name : 'Scout & Nimble'
    end

    def sale_taxon
      self.sale_taxon? ? 'sale' : ''
    end

    def product_link
      "https://#{Spree::Config.site_url.gsub(/\/$/, '')}/products/#{self.try(:slug)}"
    end

    def google_merchant_category
      return unless taxons.any?
      taxons.map{|x| x.self_and_ancestors}.flatten.map(&:name).uniq.join(" > ")
    end
  end
end
