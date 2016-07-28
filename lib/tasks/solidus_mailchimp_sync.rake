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

  desc "sync ALL data to mailchimp"
  task :bulk_sync => :environment do
    require 'ruby-progressbar'

    progress_format = '%t %c of %C |%B| %e'

    puts "\nSyncing Users, Products, and Orders to mailchimp, this could take a while...\n\n"

    if Spree.user_class
      user_count = Spree.user_class.count
      progress_bar = ProgressBar.create(total: user_count, format: progress_format, title: Spree.user_class.name.pluralize)
      Spree.user_class.find_each do |user|
        begin
          SolidusMailchimpSync::UserSynchronizer.new(user).sync
        rescue SolidusMailchimpSync::Error => e
          # just so we know what user failed.
          puts user.inspect
          raise e
        end
        progress_bar.increment
      end
      progress_bar.finish
    end

    product_count = Spree::Product.count
    progress_bar = ProgressBar.create(total: product_count, format: progress_format, title: "Spree::Products")
    Spree::Product.find_each do |product|
      SolidusMailchimpSync::ProductSynchronizer.new(product).sync
      progress_bar.increment
    end
    progress_bar.finish

    order_count = Spree::Order.count
    progress_bar = ProgressBar.create(total: order_count, format: progress_format, title: "Spree::Orders")
    Spree::Order.find_each do |order|
      SolidusMailchimpSync::OrderSynchronizer.new(order).sync
      progress_bar.increment
    end
    progress_bar.finish
  end
end
