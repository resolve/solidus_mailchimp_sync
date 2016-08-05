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
        # visibility is a string
        visibility: (visibility || '').to_s
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
      product_serializer.url
    end

    # Override in custom serializer if you want to choose which image different than `first`
    def image_url
      variant.images.first.try(:attachment).try(:url) || product_serializer.image_url
    end

    # Override for custom visibility. Mailchimp wants a string for some reason,
    # not entirely sure what the string should be.
    def visibility
      variant.product.available?.to_s
    end

    def product_serializer
      ::SolidusMailchimpSync::ProductSynchronizer.serializer_class_name.constantize.new(variant.product)
    end

  end
end
