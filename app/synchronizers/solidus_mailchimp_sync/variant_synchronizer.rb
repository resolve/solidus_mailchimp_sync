module SolidusMailchimpSync
  class VariantSynchronizer < BaseSynchronizer
    self.serializer_class_name = "::SolidusMailchimpSync::VariantSerializer"
    # Price updates are caught from after commit on Spree::Price
    self.synced_attributes = %w{id sku}

    def sync
      put
    end

    def path
      "/products/#{model.product.id}/variants/#{model.id}"
    end
  end
end
