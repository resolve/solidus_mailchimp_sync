module SolidusMailchimpSync
  # May not actually make sense to extract/abstract this stuff to BaseSynchronizer, we'll see, how
  # much other things need to vary.
  class BaseSynchronizer
    class_attribute :synced_attributes
    class_attribute :serializer_class_name

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def path
      raise TypeError, "Sub-class of BaseSynchronizer must implement #path with Solidus ecommerce API path"
    end

    # This gets a lot harder when associations are involved, haven't completely solved it.
    def synced_attributes_changed?
      (model.previous_changes.keys & synced_attributes).present?
    end

    def put
      Mailchimp.ecommerce_request(:put, path, body: serializer.to_json)
    end

    def delete
      Mailchimp.ecommerce_request(:delete, path)
    end

    def serializer
      @serializer ||= serializer_class_name.constantize.new(model)
    end
  end
end
