require 'spec_helper'

describe SolidusMailchimpSync::UserSynchronizer do
  let(:user) { create(:user, email: "jonathan@friendsoftheweb.org") }

  before do
    delete_if_present "/customers/#{user.id}"
  end

  describe "with vcr", vcr: true do
    it "first time syncs" do
      syncer = SolidusMailchimpSync::UserSynchronizer.new(user)
      response = syncer.sync

      expect(response["id"]).to eq(user.id.to_s)
      expect(response["email_address"]).to eq(user.email)
    end
  end
end
