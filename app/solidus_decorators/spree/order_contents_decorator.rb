Spree::OrderContents.class_eval do
  # If OrderContents update the order, we need to flag it so order knows to sync after it's
  # saved, even if totals don't actually change. maybe the new product is exactly
  # the same price as old one etc.
  prepend(Module.new do
    def reload_totals
      super.tap do
        order.mailchimp_auto_sync_needed = true
      end
    end
  end)


end
