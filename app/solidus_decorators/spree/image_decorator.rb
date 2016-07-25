Spree::Image.class_eval do
  after_commit :mailchimp_sync

  private
  def mailchimp_sync
    if self.viewable && self.viewable.is_a?(Spree::Variant)
      if self.viewable.is_master?
        # Need to sync all variants.
        SolidusMailchimpSync::ProductSynchronizer.new(self.viewable.product).maybe_sync_after_commit(force: true)
      else
        # image just on this variant, just need to sync this one.
        SolidusMailchimpSync::VariantSynchronizer.new(self.variant).maybe_sync_after_commit(force: true)
      end
    end
  end
end
