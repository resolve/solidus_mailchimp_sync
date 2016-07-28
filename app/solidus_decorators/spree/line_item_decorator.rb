Spree::LineItem.class_eval do
  after_commit :mailchimp_sync

  def mailchimp_sync
    SolidusMailchimpSync::OrderSynchronizer.new(order).auto_sync(force: true)
  end
end
