module SpreeGoogleMerchant
  class LinkshareCancellationFeedBuilder

    def self.generate_and_transfer
      generate
      transfer
    end

    def self.generate
      Rails.logger.info "Generating #{Spree::GoogleMerchant::Config[:linkshare_ftp_cancellation_filename]}"
      orders = Spree::Order.where("created_at > :days_ago AND (state = :cancelled_state OR state = :returned_state)", cancelled_state: 'canceled', days_ago: 1.month.ago.strftime("%Y-%m-%d"), returned_state: 'returned')

      CSV.open(self.path, "wb", {:col_sep => "\t"}) do |csv|
        orders.each do |order|
          order_state = order.state
          order.shipments.each do |shipment|
            shipment.manifest.each do |item|
              item.states.each do |state,quantity|
                if order_state == 'canceled' || (order_state == 'returned' && state == 'returned')
                  line_item = order.find_line_item_by_variant(item.variant)
                  Rails.logger.info "adding #{line_item.sku} from order #{order.id}"
                  csv << [
                    order.number,
                    '',
                    order.completed_at.strftime("%Y-%m-%d"),
                    order.completed_at.strftime("%Y-%m-%d"),
                    item.variant.sku,
                    quantity,
                    (item.variant.price.to_f * quantity * -100).to_i,
                    'USD',
                    '', '', '',
                    item.variant.name
                  ]
                end
              end
            end
          end
        end
      end
    end


    def self.transfer
      ftp_domain = 'mftp.linksynergy.com'
      username = Spree::GoogleMerchant::Config[:linkshare_ftp_username]
      password = Spree::GoogleMerchant::Config[:linkshare_ftp_password]
      filename = Spree::GoogleMerchant::Config[:linkshare_ftp_cancellation_filename]

      ftp = Net::FTP.new(ftp_domain)
      ftp.passive = true
      ftp.login(username, password)
      ftp.put(self.path, filename)
      ftp.quit
    end

    def self.path
      File.join(Rails.root, "tmp", Spree::GoogleMerchant::Config[:linkshare_ftp_cancellation_filename])
    end
  end
end
