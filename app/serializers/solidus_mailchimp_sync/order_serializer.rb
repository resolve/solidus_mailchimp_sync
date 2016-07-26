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

    # TODO checkout_url
    def as_json
      {
        id: order.id.to_s,
        customer: {
          id: order.user.id.to_s
        },
        currency_code: order.currency,
        order_total: order.total.to_f,
        tax_total: order.tax_total.to_f,
        lines: line_items
      }
    end

    def to_json
      JSON.dump(as_json)
    end

    def line_items
      order.line_items.collect do |line_item|
        LineItemSerializer.new(line_item).as_json
      end
    end
  end
end
