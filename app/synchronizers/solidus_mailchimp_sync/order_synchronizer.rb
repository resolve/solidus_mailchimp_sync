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
      if order_is_cart?
        cart_path
      else
        order_path
      end
    end

    def create_path
      if order_is_cart?
        create_cart_path
      else
        create_order_path
      end
    end

    def should_sync?
      model.mailchimp_auto_sync_needed || super
    end

    def auto_sync(*args)
      super
      mailchimp_auto_sync_needed = false
    end

    def sync
      # If we don't have a user with an email address we can't sync -- mailchimp
      # carts and orders require a customer, which requires an email address.
      unless model.user.present? && model.user.send(UserSynchronizer.email_address_attribute).present?
        return nil
      end

      if model.line_items.empty?
        # Can't sync an empty cart to mailchimp, delete if we've already synced,
        # and bail out.
        return delete(path, ignore_404: true)
      end

      if !order_is_cart?
        # delete any previous cart version of this order, but ignore if it's not there
        delete(cart_path, ignore_404: true)
      end

      post_or_patch(post_path: create_path, patch_path: path)
    rescue SolidusMailchimpSync::Error => e
      tries ||= 0 ; tries += 1
      if tries <= 1 && user_not_synced_error?(e)
        SolidusMailchimpSync::UserSynchronizer.new(model.user).sync
        retry
      else
        raise e
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

    def user_not_synced_error?(e)
      e.status == 400 &&
        e.response_hash["errors"].present? &&
        e.response_hash["errors"].any? { |h| %w{customer.email_address customer.opt_in_status}.include? h["field"] }
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
