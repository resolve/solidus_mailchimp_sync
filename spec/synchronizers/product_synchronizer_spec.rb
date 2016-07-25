require 'spec_helper'

describe SolidusMailchimpSync::ProductSynchronizer do
  let(:product) { create(:product, name: "PRODUCT NAME") }

  before do
    SolidusMailchimpSync::Mailchimp.ecommerce_request(:delete, "/products/#{product.id}") rescue nil
  end

  describe "with VCR", vcr: true do
    it "first time sync" do
      syncer = SolidusMailchimpSync::ProductSynchronizer.new(product)
      response = syncer.sync

      expect(response["id"]).to eq(product.id.to_s)
      expect(response["title"]).to eq(product.name)
      expect(
        response["variants"].all? do |v|
          v["url"] == spree.product_path(product, host: Rails.application.routes.default_url_options[:host])
        end
      )
    end

    describe "existing product sync" do
      before do
        SolidusMailchimpSync::ProductSynchronizer.new(product).sync
      end
      it "updates variants" do
        product.update(name: "NEW NAME")
        syncer = SolidusMailchimpSync::ProductSynchronizer.new(product)
        response = syncer.sync

        expect( response.all? { |v| v["title"] == "NEW NAME" })
      end
    end
  end
end
