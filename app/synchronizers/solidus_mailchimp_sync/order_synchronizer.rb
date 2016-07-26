module SolidusMailchimpSync
  # Syncs solidus orders to mailchimp Carts and Orders, adding/deleting
  # as cart status changes.
  class OrderSynchronizer < BaseSynchronizer
    self.serializer_class_name = "::SolidusMailchimpSync::OrderSerializer"
    # Not sure if tracking synced attributes is okay here, we might need
    # an update even if none of these change, although it would be unusual.
    # But we'll try it.
    self.synced_attributes = %w{total completed_at included_tax_total additional_tax_total item_count item_total}

    def path
      raise NameError, "Can't call #path on #{self.class.name}, need `cart_path` or `order_path`"
    end


    def sync
      if order_is_cart?
        post_or_patch(post_path: create_cart_path, patch_path: cart_path)
      else
        # delete, but ignore if it's not there
        response = delete(cart_path, return_errors: true)
        raise response if response.kind_of?(SolidusMailchimpSync::Error) && response.status != 404

        post_or_patch(post_path: create_order_path, patch_path: order_path)
      end
    end

    def order_is_cart?
      model.completed_at.blank?
    end

    def post_or_patch(post_path:, patch_path:)
      post(post_path)
    rescue SolidusMailchimpSync::Error => e
      if e.status == 400 && e.detail =~ /already exists/
        patch(patch_path)
      else
        raise e
      end
    end

    def mailchimp_cart
      get(cart_path)
    rescue SolidusMailchimpSync::Error => e
      raise e if e.status != 404
    end

    def cart_path
      "/carts/#{model.id}"
    end

    def create_cart_path
      "/carts"
    end

    def order_path
      "/orders/#{model.id}"
    end

    def create_order_path
      "/orders"
    end
  end
end
