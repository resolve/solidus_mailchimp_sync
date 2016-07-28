module SolidusMailchimpSync
  class VariantSynchronizer < BaseSynchronizer
    self.serializer_class_name = "::SolidusMailchimpSync::VariantSerializer"
    # Price updates are caught from after commit on Spree::Price
    self.synced_attributes = %w{id sku}

    def sync
      put
    rescue SolidusMailchimpSync::Error => e
      tries ||= 0 ; tries += 1
      if tries <= 1 && e.status == 400 && e.title == 'Parent Product Does Not Exist'
        ProductSynchronizer.new(model.product).sync
        retry
      else
        raise e
      end
    end

    def path
      "/products/#{model.product.id}/variants/#{model.id}"
    end
  end
end
