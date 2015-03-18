require 'spec_helper'

describe SpreeGoogleMerchant::FeedBuilder do
  describe 'as instance' do
    before{ @output = '' }
    describe 'in general' do
      before(:each) do
        Spree::GoogleMerchant::Config.set(:public_domain => 'http://mydomain.com')
        Spree::GoogleMerchant::Config.set(:store_name => 'Froggies')

        @builder = SpreeGoogleMerchant::FeedBuilder.new
        @xml = Builder::XmlMarkup.new(:target => @output, :indent => 2, :margin => 1)

        variant = create :variant
        variant.stub google_merchant_availability: 'in stock', google_merchant_size: 'XXL'

        @product = create(:product, variants: [ variant ])
        @product.stub google_merchant_available?: true, google_merchant_brand: 'Reformation', google_merchant_taxon: 'Group', max_image_url: '/url'

        @builder.stub products_url: "/products/#{@product.permalink}"
        @builder.build_feed_item(@xml, @product)
      end

      it 'should include products in the output' do
        @output.should include(@product.name)
        @output.should include("products/#{@product.permalink}")
        @output.should include(@product.price.to_s)
      end

      it 'should build the XML and not bomb' do
        @builder.generate_xml @output

        @output.should =~ /#{@product.name}/
        @output.should =~ /Froggies/
      end

    end

    describe 'w/out stores' do

      before(:each) do
        Spree::GoogleMerchant::Config.set(:public_domain => 'http://mydomain.com')
        Spree::GoogleMerchant::Config.set(:store_name => 'Froggies')

        @builder = SpreeGoogleMerchant::FeedBuilder.new
      end

      it "should know its path" do
        @builder.path.should == "#{::Rails.root}/tmp/data_feed.xml"
      end

      it "should initialize with the correct domain" do
        @builder.domain.should == Spree::GoogleMerchant::Config[:public_domain]
      end

      it "should initialize with the correct title" do
        @builder.title.should == Spree::GoogleMerchant::Config[:store_name]
      end

      it 'should include configured meta' do
        @xml = Builder::XmlMarkup.new(:target => @output, :indent => 2, :margin => 1)
        @product = create(:product)

        @builder.build_meta(@xml)

        @output.should =~ /Froggies/
        @output.should =~ /http:\/\/mydomain.com/
      end
    end
  end
end
