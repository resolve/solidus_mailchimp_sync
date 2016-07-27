require 'spec_helper'

describe SolidusMailchimpSync::UserSynchronizer, vcr: true do
  let(:syncer) { SolidusMailchimpSync::UserSynchronizer.new(user) }
  let(:user) { create(:user, email: "test-user-synchronizer@friendsoftheweb.org") }

  before do
    delete_if_present "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(user)}"
  end
  after do
    delete_if_present "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(user)}"
  end


  describe "new user" do
    it "syncs" do
      response = syncer.sync

      expect(response["id"]).to eq(SolidusMailchimpSync::UserSynchronizer.customer_id(user))
      expect(response["email_address"]).to eq(user.email)
    end
  end

  describe "already exists on mailchimp" do
    before do
      syncer.sync
      # Ensure it's present
      response = SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(user)}")
    end
    it "syncs" do
      syncer.sync
    end
  end

end
