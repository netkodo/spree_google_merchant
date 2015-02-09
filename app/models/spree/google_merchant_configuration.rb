module Spree
  class GoogleMerchantConfiguration < Preferences::Configuration
    preference :title, :string, :default => ''
    preference :store_name, :string, :default => ''
    preference :description, :text, :default => ''
    preference :ftp_username, :string, :default => ''
    preference :ftp_password, :password, :default => ''
    preference :product_category, :string, :default => ''
    # No default value provided
    # Omit trailing slash when setting
    #
    preference :public_domain, :string

    # Amazon product ads preferences
    preference :amazon_sftp_username, :text, :default => ''
    preference :amazon_sftp_password, :password, :default => ''

    # eBay product ads preferences
    preference :ebay_ftp_username, :text, :default => ''
    preference :ebay_ftp_password, :password, :default => ''

    # Bing product ads preferences
    preference :bing_sftp_username, :string, :default => ''
    preference :bing_sftp_password, :password, :default => ''

    preference :linkshare_ftp_username, :string, :default => ''
    preference :linkshare_ftp_password, :password, :default => ''
    preference :linkshare_ftp_filename, :filename, :default => ''
  end
end
