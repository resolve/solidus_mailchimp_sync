require 'digest/md5'

module SolidusMailchimpSync
  module Util
    # lowercased then MD5 hashed.
    # http://developer.mailchimp.com/documentation/mailchimp/guides/manage-subscribers-with-the-mailchimp-api/
    # Mailchimp does not support non-ascii chars in email addresses as of Aug 2016 according to support.
    def self.subscriber_hash(email_address)
      Digest::MD5.hexdigest(email_address.downcase)
    end
  end
end
