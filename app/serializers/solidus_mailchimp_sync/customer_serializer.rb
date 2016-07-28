require 'json'

module SolidusMailchimpSync
  # ONLY includes email address. Everyone has their own user class,
  # use a custom serializer to serialize other stuff. To change where
  # email address is stored in user record, be sure to set
  # SolidusMailchimpSync::UserSynchronizer.email_address_attribute
  class CustomerSerializer
    attr_reader :user

    def initialize(user)
      @user = user
      unless user.persisted?
        raise ArgumentError, "Can't serialize a non-saved user: #{user}"
      end
    end

    def as_json
      # Note mailchimp does not let us change email address, it won't be updated on
      # subsequent pushes. So our mailchimp id includes the email address,
      # and new mailchimp Customer will be created if email address changes.
      {
        'id' => UserSynchronizer.customer_id(user),
        'email_address' => user.send(UserSynchronizer.email_address_attribute),
        'opt_in_status' => false
      }
    end

    def to_json
      JSON.dump(as_json)
    end

  end
end
