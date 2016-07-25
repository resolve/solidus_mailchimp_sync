module SolidusMailchimpSync
  # Individual synchronizers will implement a #sync method, which will be run
  # under an ActiveJob so won't have access to previous state.
  #
  # Individual synchornizers also set serializer_class_name, and synced_attributes,
  # and override #path with Mailchimp API path.  May also override other methods.
  class BaseSynchronizer
    class_attribute :synced_attributes
    class_attribute :serializer_class_name
    class_attribute :auto_sync_enabled
    auto_sync_enabled = true

    attr_reader :model

    def initialize(model)
      @model = model
    end

    def path
      raise TypeError, "Sub-class of BaseSynchronizer must implement #path with Solidus ecommerce API path"
    end

    # Designed to be called in an after commit hook, syncs in bg, if
    # neccessary.
    def auto_sync(force: false)
      if auto_sync_enabled && (force || should_sync?)
        SolidusMailchimpSync::SyncJob.perform_later(self.class.name, model)
      end
    end

    # in an after-commit situation, we can tell new record from id changed
    def was_newly_inserted?
      pk_changed = model.previous_changes[model.class.primary_key]

      pk_changed && pk_changed.first.nil? && pk_changed.second.present?
    end

    def should_sync?
      was_newly_inserted? && synced_attributes_changed?
    end

    # This gets a lot harder when associations are involved, haven't completely solved it.
    def synced_attributes_changed?
      (model.previous_changes.keys & synced_attributes).present?
    end

    def put
      Mailchimp.ecommerce_request(:put, path, body: serializer.as_json)
    end

    def delete
      Mailchimp.ecommerce_request(:delete, path)
    end

    def post
      Mailchimp.ecommerce_request(:post, create_path, body: serializer.as_json)
    end

    def serializer
      @serializer ||= serializer_class_name.constantize.new(model)
    end
  end
end
