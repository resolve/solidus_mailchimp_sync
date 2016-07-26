require 'json'

module SolidusMailchimpSync
  # Line item for Cart or Order, mailchimp serializes the same
  class LineItemSerializer
    attr_reader :line_item

    def initialize(line_item)
      @line_item = line_item
    end

    def as_json
      {
        id: line_item.id.to_s,
        product_id: line_item.product.id.to_s,
        product_variant_id: line_item.variant.id.to_s,
        quantity: line_item.quantity,
        price: line_item.price
      }
    end

    def to_json
      JSON.dump(as_json)
    end
  end
end
