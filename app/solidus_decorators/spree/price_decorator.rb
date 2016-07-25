Spree::Price.class_eval do
  after_commit :mailchimp_sync

  private
  def mailchimp_sync
    if self.variant
      SolidusMailchimpSync::VariantSynchronizer.new(self.variant).auto_sync(force: true)
    end
  end
end
