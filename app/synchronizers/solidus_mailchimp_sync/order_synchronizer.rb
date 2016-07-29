module SolidusMailchimpSync
  # Syncs solidus orders to mailchimp Carts and Orders, adding/deleting
  # as cart status changes.
  class OrderSynchronizer < BaseSynchronizer
    self.serializer_class_name = "::SolidusMailchimpSync::OrderSerializer"
    # We update on all state changes, even though some might not really
    # require a mailchimp sync, it just depends on what we're serializing.
    # Also, when solidus sets completed_at, it seems not to trigger
    # an after_commit, so we can't catch transition to complete that way.
    #
    # We used to update on changes to any totals thinking we could catch
    # line item changes that way -- but removing a line item and adding
    # another with the exact same price wouldn't trigger total changes, so
    # we had to trap all line item changes instead on a LineItem decorator,
    # so sync'ing on changes to order totals isn't neccesary just causes
    # extra superfluous syncs.
    self.synced_attributes = %w{state}

    class_attribute :line_item_serializer_class_name
    self.line_item_serializer_class_name = "::SolidusMailchimpSync::LineItemSerializer"

    def path
      if order_complete?
        order_path
      else
        cart_path
      end
    end

    def create_path
      if order_complete?
        create_order_path
      else
        create_cart_path
      end
    end

    def sync
      # If we don't have a user with an email address we can't sync -- mailchimp
      # carts and orders require a customer, which requires an email address.
      unless model.user.present? && model.user.send(UserSynchronizer.email_address_attribute).present?
        return nil
      end

      # Can't sync an empty cart to mailchimp, delete the cart/order if
      # we've previously synced, and bail out of this sync.
      if model.line_items.empty?
        return delete(path, ignore_404: true)
      end

      # if it's a completed order, delete any previous synced _cart_ version
      # of this order, if one is present. There should be no Mailchimp 'cart',
      # only a mailchimp 'order' now.
      #byebug
      if order_complete?
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

    def order_complete?
      # Yes, somehow solidus can sometimes, temporarily, in our after commit hook
      # have state==complete set, but not completed_at
      model.completed? || model.state == "complete"
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
