require 'json'

module SolidusMailchimpSync
  # Right now ONLY includes email address. Including other attributes in a
  # re-usable gem is tricky because everyone has their own user class.
  # But there are various approaches we could use.
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
      # subsequent pushes. TODO we have to delete and re-create the user, argh!!!
      {
        'id' => user.id.to_s,
        'email_address' => user.email,
        'opt_in_status' => false
      }
    end

    def to_json
      JSON.dump(as_json)
    end

  end
end
