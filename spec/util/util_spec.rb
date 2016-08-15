require 'spec_helper'

describe SolidusMailchimpSync::Util do
  describe ".subsriber_hash" do
    # http://developer.mailchimp.com/documentation/mailchimp/guides/manage-subscribers-with-the-mailchimp-api/
    # Mailchimp does not support non-ascii chars in email addresses as of Aug 2016 according to support.
    it "matches doc example" do
      expect(SolidusMailchimpSync::Util.subscriber_hash('Urist.McVankab@freddiesjokes.com')).to eq('62eeb292278cc15f5817cb78f7790b08')
    end
  end
end
