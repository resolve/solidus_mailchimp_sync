namespace :solidus_mailchimp_sync do
  desc "Create a Mailchimp Store. ENV LIST_ID param is required"
  task create_mailchimp_store: :environment do
    unless ENV["LIST_ID"].present?
      raise ArgumentError, "LIST_ID env arg is required. Your mailchimp Listserv ID."
    end

    response = SolidusMailchimpSync::Mailchimp.request(:post, "/ecommerce/stores", body: {
      list_id: ENV["LIST_ID"],
      id: ENV["NEW_STORE_ID"] || (Spree::Store.default.name || "solidus").parameterize,
      name: Spree::Store.default.name || "Solidus",
      currency_code: Spree::Store.default.default_currency || 'USD'
    })
    store_id = response["id"]

    raise TypeError, "Unexpected response from Mailchimp, can't find created store id" unless store_id.present?

    puts "\nNew Mailchimp Store created with id: `#{store_id}`"
    puts
    puts "You probably want to add to your ./config/initializers/solidus_mailchimp_sync.rb:"
    puts
    puts "   SolidusMailchimpSync.store_id='#{store_id}'"
    puts
  end
end
