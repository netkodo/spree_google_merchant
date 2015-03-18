require 'spec_helper'

describe Spree::Product do

  context "with GoogleMerchant support" do
    let(:product) { create(:product) }

    it 'should have a saved product record' do
      expect(product.new_record?).to be false
    end

    it 'should have google_merchant_condition' do
      product.google_merchant_condition.should_not be_nil
    end

    it 'should have google_merchant_description' do
      product.google_merchant_description.should_not be_nil
    end

    context 'w/ Brand property defined' do
      # Taken from the core filters parametrized example
      # /core/lib/spree/product_filters.rb
      #
      before do
        property = create(:property, :name => 'brand')
        create(:product_property, :value => 'Brand Name', :property_name => 'brand', :product => product)
      end
    end

    context 'without images' do
      before do
        product.images.clear
      end
      specify { product.google_merchant_image_link.should be_nil }
    end

    context 'with images' do
      before(:each) do
        image = create(:image, :viewable => product)
        product.images << image
        product.reload

        Spree::GoogleMerchant::Config.set(:public_domain => 'http://mydomain.com')
      end

      specify { product.google_merchant_image_link.should_not be_nil }

      it 'should output the image url with the specified domain' do
        image_link = product.google_merchant_image_link
        #image_link.should == "#{Spree::GoogleMerchant::Config[:public_domain]}#{product.images[0].attachment.url(:product)}"
      end
    end

  end

end
