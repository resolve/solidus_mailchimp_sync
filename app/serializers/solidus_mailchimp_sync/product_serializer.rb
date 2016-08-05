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

    # We have to include image and URL for certain mailchimp features,
    # although Mailchimp does NOT let us update/edit a sync'd product, grr.
    def as_json
      hash = {
        id: product.id.to_s,
        handle: product.slug,
        title: product.name,
        description: product.description,
        variants: variants_json
      }

      if url = self.url
        hash[:url] = url
      end

      if image_url = self.image_url
        hash[:image_url] = image_url
      end

      if product.available_on
        hash[:published_at_foreign] = product.available_on.iso8601
      end

      hash
    end

    # Override in custom serializer for custom front-end url
    def url
      if Rails.application.routes.default_url_options[:host] && Spree::Core::Engine.routes.url_helpers.respond_to?(:product_url)
        Spree::Core::Engine.routes.url_helpers.product_url(product, host: Rails.application.routes.default_url_options[:host])
      end
    end

    # Override in custom serializer if you want to choose which image different than `first`
    def image_url
      product.images.first.try(:attachment).try(:url)
    end

    def variants_json
      sellable_variants.collect do |variant|
        VariantSynchronizer.new(variant).serializer.as_json
      end
    end

    def sellable_variants
      if (product.association(:variants).loaded? ? product.variants.length > 0 : product.variants.exists?)
        product.variants
      else
        [product.master]
      end
    end

    def to_json
      JSON.dump(as_json)
    end
  end
end
