module SolidusMailchimpSync
  class UserSynchronizer < BaseSynchronizer
    self.serializer_class_name = "::SolidusMailchimpSync::CustomerSerializer"
    self.synced_attributes = ['email']

    # synchronizers local user to Mailchimp customer. Whether Customer
    # already existed on mailchimp end or not. Deletes if deleted.
    def sync
      if model.deleted?
        delete
      else
        put
      end
    end

    def path
      "/customers/#{model.id}"
    end
  end
end
