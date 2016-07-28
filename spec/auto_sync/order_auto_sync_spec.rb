require 'spec_helper'

# Not sure the best way to test this stuff, this might not be it, but is
# a try.

# need truncation instead of transaction db cleaner, so our after_commit
# hooks happen!
describe "Auto-sync on Spree::Order", clean: :truncation do
  around do |example|
    # Enable auto-sync so we can test it, but disable actually talking
    # to Mailchimp, we'll mock that part, it's not what we're testing here.

    orig_enabled = SolidusMailchimpSync.enabled
    SolidusMailchimpSync.enabled = false

    orig_auto_sync = SolidusMailchimpSync.auto_sync_enabled
    SolidusMailchimpSync.auto_sync_enabled = true

    example.run

    SolidusMailchimpSync.auto_sync_enabled = orig_auto_sync
    SolidusMailchimpSync.enabled = orig_enabled
  end


  describe "cart to order" do
    let(:order) { create(:order_ready_to_complete) }

    it "deletes and creates" do
      expect_any_instance_of(SolidusMailchimpSync::OrderSynchronizer).to receive(:delete).
        with("/carts/#{order.id}", {:ignore_404=>true})

      expect_any_instance_of(SolidusMailchimpSync::OrderSynchronizer).to receive(:post_or_patch).
        with(post_path: "/orders", patch_path: "/orders/#{order.id}")

      order.complete!
    end
  end

  describe "modify a cart" do
    let!(:variant) { create(:variant) }
    let!(:order) { create(:order, state: 'cart') }
    it "syncs after add" do
      # Not sure why it's being sent more than once, but we'll allow it.
      expect(SolidusMailchimpSync::Mailchimp).to receive(:ecommerce_request) do |method, path, options|
        expect(method).to eq(:post)
        expect(path).to eq("/carts")
      end.at_least(:once)

      order.contents.add(variant)
    end
  end

  describe "modify with update and exact same price in the end" do
    let(:price) { 10.0.to_d }
    let!(:variant1) { create(:variant, price: price) }
    let!(:variant2) { create(:variant, price: price) }
    let!(:order) { create(:order, state: 'cart').tap { |o| o.contents.add(variant1, 1) } }

    # This is the really tricky one, that we're currently handling by syncing order
    # on any line item after_commit, which also results in extra unneccesary syncs,
    # in order to get this neccesary one.
    it "still syncs" do
      expect(SolidusMailchimpSync::Mailchimp).to receive(:ecommerce_request) do |method, path, options|
        expect(method).to eq(:post)
        expect(path).to eq("/carts")
      end.at_least(:once)

      order.contents.update_cart(line_items_attributes: [{id: order.line_items.first.id, quantity: 0}, { variant_id: variant2.id, quantity: 1 }])
    end

  end

end
