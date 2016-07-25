Spree::Product.class_eval do
  after_commit :mailchimp_sync

  private
  def mailchimp_sync
    SolidusMailchimpSync::ProductSynchronizer.new(self).auto_sync
  end
end
