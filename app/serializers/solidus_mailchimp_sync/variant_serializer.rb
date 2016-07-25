require 'json'

module SolidusMailchimpSync
  class VariantSerializer
    attr_reader :variant

    # TODO url, and variant visibility
    # TODO image
    def initialize(variant)
      @variant = variant
      unless variant.persisted?
        raise ArgumentError, "Can't serialize a non-saved variant: #{variant}"
      end
    end

    def as_json
      {
        id: variant.id.to_s,
        title: title,
        sku: variant.sku,
        price: variant.price.to_f,

        visiiblity: true
      }
    end

    def to_json
      JSON.dump(as_json)
    end

    def title
      [variant.product.name, variant.options_text].delete_if {|a| a.blank? }.join(':')
    end

  end
end
