require 'json'

module SolidusMailchimpSync
  # in progress
  class ProductSerializer
    attr_reader :product
    def initializer(product)
      @product = product
      unless user.persisted?
        raise ArgumentError, "Can't serialize a non-saved product: #{product}"
      end
    end

    def as_json
      {
        id: product.id,
        handle: product.slug,
        name: product.name,
        description: product.description,
        image_url: image_url,
        variants: variants
      }
    end

    def to_json
      JSON.dump(as_json)
    end

    # Override to pick differently
    def image_url
      images.first.try do |image|
        image.attachment.image
      end
    end

    def variants

    end
  end
end
