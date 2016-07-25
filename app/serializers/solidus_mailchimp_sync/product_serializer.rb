require 'json'

module SolidusMailchimpSync
  # Intentionally does not sync images, let variants do that.
  #
  class ProductSerializer
    attr_reader :product

    def initialize(product)
      @product = product
      unless product.persisted?
        raise ArgumentError, "Can't serialize a non-saved product: #{product}"
      end
    end

    # We don't include image or url, variants can have those anyway,
    # and variants are actually editable, do it there.
    def as_json
      {
        id: product.id.to_s,
        handle: product.slug,
        title: product.name,
        description: product.description,
        published_at_foreign: product.available_on.iso8601,
        variants: variants_json
      }
    end

    def variants_json
      product.variants_including_master.collect do |variant|
        VariantSynchronizer.new(variant).serializer.as_json
      end
    end

    def to_json
      JSON.dump(as_json)
    end
  end
end
