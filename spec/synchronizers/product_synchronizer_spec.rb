require 'spec_helper'

describe SolidusMailchimpSync::ProductSynchronizer do
  let(:product) { create(:product, name: "PRODUCT NAME") { |p| p.images << create(:image, attachment_updated_at: Time.new(2016, 5, 5, 10, 10, 10, "+05:00")) } }

  before do
    delete_if_present("/products/#{product.id}")
  end

  describe "with VCR", vcr: true do
    it "first time sync" do
      syncer = SolidusMailchimpSync::ProductSynchronizer.new(product)
      response = syncer.sync

      expect(response["id"]).to eq(product.id.to_s)
      expect(response["title"]).to eq(product.name)

      expected_url = spree.product_url(product, host: Rails.application.routes.default_url_options[:host])
      expect(response["url"]).to eq(expected_url)
      expect(
        response["variants"].all? do |v|
          v["url"] == expected_url
        end
      )

      expect(response["image_url"]).to eq(product.images.first.attachment.url)
      expect(
        response["variants"].all? do |v|
          v["image_url"] == product.images.first.attachment.url
        end
      )
    end

    describe "with variants" do
      let(:product) do
        create(:product, name: "PRODUCT NAME") do |p|
          2.times { |i| p.variants << create(:variant, product: p, sku: "PROD_SYNC_SKU_#{i}") }
        end
      end

      it "does not sync master variant" do
        syncer = SolidusMailchimpSync::ProductSynchronizer.new(product)
        response = syncer.sync

        expect(response["variants"].length).to eq(product.variants.length)
        product.variants.each do |v|
          expect(response["variants"].find_all { |vh| vh["sku"] == v.sku}.count).to eq(1)
        end
        expect(response["variants"].none? { |vh| vh["sku"] == product.master.sku }).to be(true)
      end
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

        describe "auto syncing" do
          it "is not should_sync?" do
            syncer = SolidusMailchimpSync::ProductSynchronizer.new(product)
            expect(syncer.should_sync?).to be(false)
          end
          it "does not auto_sync" do
            syncer = SolidusMailchimpSync::ProductSynchronizer.new(product)
            result = syncer.auto_sync
            expect(result).to be(nil)
            error = SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/products/#{product.id}", return_errors: true)
            expect(error.status).to eq(404)
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
