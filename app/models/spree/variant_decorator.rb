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
    format("%.2f %s", price, self.currency).to_s
  end

  def google_merchant_sale_price
    return if !self.product.sale_display or self.sale_price.blank?
    format("%.2f %s", self.sale_price, self.currency).to_s
  end

end
