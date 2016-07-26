module SolidusMailchimpSync
  class UserSynchronizer < BaseSynchronizer
    self.serializer_class_name = "::SolidusMailchimpSync::CustomerSerializer"
    self.synced_attributes = ['email']

    class_attribute :email_address_attribute
    self.email_address_attribute = :email

    # synchronizers local user to Mailchimp customer. Whether Customer
    # already existed on mailchimp end or not. Deletes if deleted.
    def sync
      if model.send(email_address_attribute).blank?
        # can't sync a user without an email address, mailchimp doesn't allow it
        return nil
      end

      if model.deleted?
        delete
      else
        put
      end
    end

    def path
      "/customers/#{model.id}"
    end

    # ID used to identify a user on mailchimp. Mailchimp does not
    # allow ID's to change, even though we do, so care is needed.
    def self.customer_id(user)
      "#{user.id}-#{user.email}"
    end

  end
end
