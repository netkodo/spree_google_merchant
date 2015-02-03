module Spree
  class ProductAd < ActiveRecord::Base
    belongs_to :variant
    belongs_to :product_ad_channel
    belongs_to :channel, :class_name => :ProductAdChannel, :foreign_key => "product_ad_channel_id"
    scope :active, -> {where("spree_product_ads.state <> 'disabled'")}
    #attr_accessible :channel, :variant, :state, :max_cpc
  end
end
