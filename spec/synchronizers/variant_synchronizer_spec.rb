require 'spec_helper'

describe SolidusMailchimpSync::VariantSynchronizer, vcr: true do
  let(:syncer) { SolidusMailchimpSync::VariantSynchronizer.new(variant) }

  describe "with a product not synced yet" do
    let(:variant) { create(:variant) }
    before do
      SolidusMailchimpSync::Mailchimp.ecommerce_request(:delete, "/products/#{variant.product.id}") rescue nil
    end

    it "still syncs, with product" do
      response = syncer.sync
      expect(response["id"]).to eq(variant.id.to_s)

      product_response = SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/products/#{variant.product.id}")
      expect(product_response["id"]).to eq(variant.product.id.to_s)

      variant_response = SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/products/#{variant.product.id}/variants/#{variant.id}")
      expect(variant_response["id"]).to eq(variant.id.to_s)
    end
  end
end
