require 'spec_helper'

describe SolidusMailchimpSync::UserSynchronizer do
  let(:user) { create(:user, email: "test-user-synchronizer@friendsoftheweb.org") }

  before do
    delete_if_present "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(user)}"
  end
  after do
    delete_if_present "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(user)}"
  end

  describe "with vcr", vcr: true do
    it "first time syncs" do
      syncer = SolidusMailchimpSync::UserSynchronizer.new(user)
      response = syncer.sync

      expect(response["id"]).to eq(SolidusMailchimpSync::UserSynchronizer.customer_id(user))
      expect(response["email_address"]).to eq(user.email)
    end
  end
end
