require 'json'

module SolidusMailchimpSync
  class VariantSerializer
    attr_reader :variant

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

        visiiblity: visibility
      }

      url = self.url
      hash[:url] = url if url

      image_url = self.image_url
      hash[:image_url] = image_url if image_url

      hash
    end

    def to_json
      JSON.dump(as_json)
    end

    def title
      [variant.product.name, variant.options_text].delete_if { |a| a.blank? }.join(' ')
    end

    # Override in custom serializer for custom front-end url
    def url
      if Rails.application.routes.default_url_options[:host] && Spree::Core::Engine.routes.url_helpers.respond_to?(:product_url)
        Spree::Core::Engine.routes.url_helpers.product_url(variant.product, host: Rails.application.routes.default_url_options[:host])
      end
    end

    # Override in custom serializer if you want to choose which image different than `first`
    def image_url
      (variant.images.first || variant.product.images.first).try(:url)
    end

    # Override for custom visibility.
    def visibility
      variant.product.available?
    end
  end
end
