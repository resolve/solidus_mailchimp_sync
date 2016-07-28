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
end
