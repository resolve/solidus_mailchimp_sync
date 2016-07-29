require 'json'

module SolidusMailchimpSync
  # Serializes to Mailchimp Cart or Order, depending on state.
  class OrderSerializer
    attr_reader :order

    def initialize(order)
      @order = order
      unless order.persisted?
        raise ArgumentError, "Can't serialize a non-saved order: #{order}"
      end
    end

    def as_json
      hash = {
        id: order.id.to_s,
        customer: {
          id: UserSynchronizer.customer_id(order.user)
        },
        currency_code: order.currency,
        order_total: order.total.to_f,
        tax_total: order.tax_total.to_f,
        lines: line_items
      }


      # Mailchimp does not take URLs for orders, just carts
      unless order_complete?
        url = cart_url
        hash["checkout_url"] = url if url
      end

      hash["shipping_total"] = shipping_total if shipping_total

      hash
    end

    # Override in custom serializer for custom front-end url
    def cart_url
      # Mailchimp does not take URLs for orders, just carts
      unless order_complete?
        if Rails.application.routes.default_url_options[:host] && Spree::Core::Engine.routes.url_helpers.respond_to?(:cart_url)
          Spree::Core::Engine.routes.url_helpers.cart_url(host: Rails.application.routes.default_url_options[:host])
        end
      end
    end

    def order_complete?
      # Yes, somehow solidus can sometimes, temporarily, in our after commit hook
      # have state==complete set, but not completed_at
      order.completed? || order.state == "complete"
    end

    def shipping_total
      # Mailchimp only wants shipping total for Orders, not Carts.
      order.shipment_total if order_complete?
    end

    def to_json
      JSON.dump(as_json)
    end

    def line_items
      order.line_items.collect do |line_item|
        ::SolidusMailchimpSync::OrderSynchronizer.line_item_serializer_class_name.constantize.new(line_item).as_json
      end
    end
  end
end
