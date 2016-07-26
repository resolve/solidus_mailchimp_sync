def delete_if_present(mailchimp_api_url)
  response = SolidusMailchimpSync::Mailchimp.ecommerce_request(:delete, mailchimp_api_url, return_errors: true)
  if response.kind_of?(SolidusMailchimpSync::Error) && response.status != 404
    byebug
    raise response
  end
  response
end
