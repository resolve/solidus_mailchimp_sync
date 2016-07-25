
# Strogly suggest you set your mailchimp API key in your ENV
SolidusMailchimpSync.api_key = ENV['MAILCHIMP_API_KEY']


# These ones are not especially confidential and don't need to be ENV,
# you can set them however you like:

# We need to know the id of the Mailchimp Store object. If you don't
# have one, you can create one with `rake solidus_mailchimp_sync:create_store LIST_ID=xxxx`
SolidusMailchimpSync.store_id = ENV['MAILCHIMP_STORE_ID']

# Automatic synchronization is done with ActiveJob, use a queue
# other than :default if you want:
# SolidusMailchimpSync::SyncJob.use_queue_name = :mailchimp_sync
