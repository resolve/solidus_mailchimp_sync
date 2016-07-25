module SolidusMailchimpSync
  class VariantSynchronizer < BaseSynchronizer
    self.serializer_class_name = "::SolidusMailchimpSync::VariantSerializer"
    # TODO: Price is updated, how do we sync??
    self.synced_attributes = %w{id sku}

    def sync
      put
    end

    def path
      "/products/#{model.product.id}/variants/#{model.id}"
    end
  end
end
