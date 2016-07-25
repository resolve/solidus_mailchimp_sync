Spree::Variant.class_eval do
  after_commit :mailchimp_sync

  private
  def mailchimp_sync
    SolidusMailchimpSync::VariantSynchronizer.new(self).maybe_sync_after_commit
  end
end
