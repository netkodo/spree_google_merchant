Spree::Variant.class_eval do
#  has_many :product_ads
#  after_create :create_product_ads

#  def create_product_ads
#    Spree::ProductAdChannel.all.each do |channel|
#      if product_ads.select{|ad|ad.channel == channel}.empty?
#        product_ads.create(
#          :channel => channel, 
#          :state => "enabled", 
#          :max_cpc => (self.max_cpc || channel.default_max_cpc)
#        )
#      end
#    end
#  end
# <g:price> 15.00 USD
  def google_merchant_price
    return if self.price.nil?
    format("%.2f %s", self.reload.price, self.currency).to_s
  end

  def google_merchant_identifier_exists(product)
    product.brand_name.present? and self.google_merchant_gtin.present?
  end

  def google_merchant_gtin
    upcs = self.property_variants.select{|x| x.property.name == 'upc'}
    if upcs.present?
      upc = upcs.first
      upc.value
    else
      ''
    end
  end

  def google_merchant_sale_price
    return if !self.product.sale_display or self.sale_price.blank?
    format("%.2f %s", self.sale_price, self.currency).to_s
  end

  def google_merchant_sale_time_range
    return if !self.start_sale_date.present? or !self.end_sale_date.present?
    "#{self.start_sale_date.strftime('%Y-%m-%dT%I-%M%z')}/#{self.end_sale_date.strftime('%Y-%m-%dT%I-%M%z')}"
  end

  def csv_google_merchant_images
    main_image, *more_images = self.images
    return [] unless main_image
    more_output = image_url(more_images.first) if more_images.present?
    image_output = image_url(main_image)
    return more_images.present? ? [image_output, more_output] : [image_output]
  end

  private

  def image_url(image)
    image.attachment.url(:product).sub(/\?.*$/, '').sub(/^\/\//, 'http://')
  end
end