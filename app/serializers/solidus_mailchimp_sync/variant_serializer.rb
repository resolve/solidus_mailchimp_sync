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
      hash = {
        id: variant.id.to_s,
        title: title,
        sku: variant.sku,
        price: variant.price.to_f,

        visiiblity: true
      }

      url = self.url
      hash[:url] = url if url

      hash
    end

    def to_json
      JSON.dump(as_json)
    end

    def title
      [variant.product.name, variant.options_text].delete_if {|a| a.blank? }.join(':')
    end

    # Override in custom serializer for custom front-end url
    def url
      if Rails.application.routes.default_url_options[:host] && Spree::Core::Engine.routes.url_helpers.respond_to?(:product_url)
        Spree::Core::Engine.routes.url_helpers.product_url(variant.product, host: Rails.application.routes.default_url_options[:host])
      end
    end

  end
end
