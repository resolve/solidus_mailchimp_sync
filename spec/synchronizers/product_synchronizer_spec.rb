require 'spec_helper'

describe SolidusMailchimpSync::ProductSynchronizer do
  let(:product) { create(:product, name: "PRODUCT NAME") }

  before do
    delete_if_present("/products/#{product.id}")
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

    describe "visibility" do
      describe "available" do
        let(:product) { create(:product, available_on: Time.now - 1.week) }
        before do
          # precondition
          expect(product.available?).to be(true)
        end

        it "has visibility true for variants" do
          syncer = SolidusMailchimpSync::ProductSynchronizer.new(product)
          response = syncer.sync
          # Not entirely sure if 'true' is what we want or what this means
          response["variants"].each do |response_variant|
            expect(response_variant["visibility"]).to eq("true")
          end
        end
      end

      describe 'not available' do
        let(:product) { create(:product, available_on: nil) }
        before do
          # precondition
          expect(product.available?).to be(false)
        end

        it "has visibility true for variants" do
          syncer = SolidusMailchimpSync::ProductSynchronizer.new(product)
          response = syncer.sync
          # Not entirely sure if 'false' is what we want or what this means
          response["variants"].each do |response_variant|
            expect(response_variant["visibility"]).to eq("false")
          end
        end
      end
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
