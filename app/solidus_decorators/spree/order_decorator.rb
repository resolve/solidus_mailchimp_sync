Spree::Order.class_eval do
  after_commit :mailchimp_sync

  # Changes to line items will mark this
  attr_accessor :mailchimp_auto_sync_needed

  private
  def mailchimp_sync
    SolidusMailchimpSync::OrderSynchronizer.new(self).auto_sync
  end
end
