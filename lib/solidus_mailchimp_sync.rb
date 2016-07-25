require 'solidus_core'
require 'solidus_mailchimp_sync/engine'

module SolidusMailchimpSync
  mattr_accessor :api_key
  mattr_accessor :store_id

  def self.data_center
    @data_center ||= begin
      if api_key.present?
        dc = api_key.split('-').last
        if dc.empty? || dc == api_key
          raise ArgumentError, "Mailchimp API key is expected to end in a hyphen and data center code, but was not found in `#{api_key}`, do not know how to proceed"
        end
        dc
      end
    end
  end
end
