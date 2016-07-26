require 'spec_helper'

describe SolidusMailchimpSync::OrderSynchronizer, vcr: true do
  let(:syncer) { SolidusMailchimpSync::OrderSynchronizer.new(order) }

  after do
    delete_if_present("/carts/#{order.id}")
    delete_if_present("/orders/#{order.id}")
  end

  describe "not completed order" do
    let(:order) { create(:order_with_line_items, line_items_count: 2) }
    before do
      delete_if_present("/carts/#{order.id}")
    end

    it "syncs as cart" do
      response = syncer.sync
      expect_order_equals_mailchimp_response(order: order, response: response)

      response = SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/carts/#{order.id}")
      expect(response["status"]).to be_nil
      expect(response["checkout_url"]).to eq(spree.cart_url(host: Rails.application.routes.default_url_options[:host]))
    end

    describe "existing order" do
      let(:new_variant) { create(:variant).tap { |v| SolidusMailchimpSync::VariantSynchronizer.new(v).sync } }
      before do
        syncer.sync
        # Make sure it's really there, seesm to fail sometimes, perhaps because of
        # lag on mailchimp revealing the thing it just added, doh.
        SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/carts/#{order.id}")
      end
      it "updates" do
        order.contents.remove_line_item(order.line_items.first)
        order.contents.add(new_variant)

        response = syncer.sync
        expect_order_equals_mailchimp_response(order: order, response: response)
      end

      describe "that turns into a completed order" do
        let(:order) { create(:order_ready_to_complete) }
        before do
          delete_if_present("/orders/#{order.id}")
          syncer.sync
          # make sure it's there as a cart
          SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/carts/#{order.id}")
        end

        it "deletes mailchimp cart and creates mailchimp order" do
          order.complete!
          response = syncer.sync
          expect(response["id"]).to eq(order.id.to_s)

          # Make sure order is there as an order
          SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/orders/#{order.id}")
          # and NOT as a cart
          error = SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/carts/#{order.id}", return_errors: true)
          expect(error.status).to eq(404)
        end
      end
    end

  end

  describe "completed order" do
    let(:order) { create(:completed_order_with_totals) }
    before do
      delete_if_present("/orders/#{order.id}")
    end

    it "syncs as order" do
      response = syncer.sync
      expect_order_equals_mailchimp_response(order: order, response: response)

      response = SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/orders/#{order.id}")
      expect(response["status"]).to be_nil
    end

    describe "existing order" do
      let(:new_variant) { create(:variant).tap { |v| SolidusMailchimpSync::VariantSynchronizer.new(v).sync } }
      before do
        response = syncer.sync
        # just make sure it was really created
        SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/orders/#{order.id}")
      end
      it "updates" do
        order.contents.remove_line_item(order.line_items.first)
        order.contents.add(new_variant)

        response = syncer.sync
        expect_order_equals_mailchimp_response(order: order, response: response)
      end
    end
  end

  describe "order without user" do
    let(:order) { create(:order_with_line_items, user: nil) }
    it "can't sync" do
      response = syncer.sync
      expect(response).to be_nil
    end
  end

  def expect_order_equals_mailchimp_response(order:, response:)
    expect(response["id"]).to eq(order.id.to_s)
    expect(response["customer"]["id"]).to eq(order.user.id.to_s)
    expect(response["order_total"]).to eq(order.total)
    expect(response["tax_total"]).to eq(order.tax_total)

    order.line_items.each do |line_item|
      response_line = response["lines"].find {|h| h["id"] == line_item.id.to_s }
      expect(response_line).to be_present

      expect(response_line["product_variant_id"]).to eq(line_item.variant.id.to_s)
      expect(response_line["product_id"]).to eq(line_item.product.id.to_s)
      expect(response_line["quantity"]).to eq(line_item.quantity)
      expect(response_line["price"]).to eq(line_item.price)
    end
  end
end
