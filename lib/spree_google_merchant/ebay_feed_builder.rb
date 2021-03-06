require 'net/sftp'

module SpreeGoogleMerchant
  class EbayFeedBuilder < FeedBuilder

    @@feed_attributes = [
      "Unique Merchant SKU",
      "Product Name",
      "Product URL",
      "Image URL",
      "Current Price",
      "Stock Availability",
      "Condition",
      "UPC",
      "Shipping Rate",
      "Original Price",
      "Brand",
      "Product Description",
      "Product Type",
      "Category"
    ]

    def filename
      "ebay_product_ads.txt"
    end

    def generate_xml file

      # Write header line
      @@feed_attributes.each_with_index do |attr_name, index|
        if index == 0
          file.write("#{attr_name}")
        else
          file.write("\t#{attr_name}")
        end
      end
      file.write("\n");

      # Write row for each product
      index = 0
      start_time = Time.now
      ar_scope.find_each(:batch_size => 300) do |product|
        next unless validate_record(product)
        line = ""
        @@feed_attributes.each_with_index do |attr_name, index|
          method = "ebay_#{attr_name.downcase.tr(' ', '_')}"
          value = product.send(method)
          if index == 0
            line << "#{value}"
          else
            line << "\t#{value}"
          end
        end
        file.write("#{line}\n")
        
        # Log progress to console
        if(index % 20 == 0)
          percent = (((index.to_f + 1) / (@product_count.to_f + 1)) * 100).to_i
          current_time = Time.now
          elapsed_seconds = current_time - start_time
          rate = index/elapsed_seconds
          print "#{percent}% (#{index}/#{@product_count}) (#{rate}/sec)   \r"
        end
        
        index += 1
      end
    end

    def transfer_xml
      raise "Please configure your Google Merchant :ebay_ftp_username and :ebay_ftp_password by configuring Spree::GoogleMerchant::Config" unless
          Spree::GoogleMerchant::Config[:ebay_ftp_username] and Spree::GoogleMerchant::Config[:ebay_ftp_password]

      ftp = Net::FTP.new('ftp.ebaycommercenetwork.com')
      ftp.passive = true
      ftp.login(Spree::GoogleMerchant::Config[:ebay_ftp_username], Spree::GoogleMerchant::Config[:ebay_ftp_password])
      ftp.put(path, filename)
      ftp.quit
    end

    def ar_scope
      if @store
        products = Spree::Product.by_store(@store).ebay_ads.scoped
      else
        products = Spree::Product.ebay_ads.scoped
      end
      @product_count = products.length
      products
    end

    def validate_record(product)
      return false if product.images.length == 0 && product.imagesize == 0 rescue true
      return false if product.master.stock_items.sum(:count_on_hand) <= 0
      return false if product.ebay_product_name.nil?
      return false if product.ebay_category.nil?
      return false if product.ebay_current_price.nil? || product.ebay_current_price.to_f <= 0
      return false if product.ebay_product_url.nil?
      return false if product.ebay_unique_merchant_sku.nil?
      return false unless validate_upc(product.upc)
      true
    end
  end
end