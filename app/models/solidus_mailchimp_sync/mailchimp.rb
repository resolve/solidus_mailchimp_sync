require 'json'
require 'http'
require 'solidus_mailchimp_sync'

module SolidusMailchimpSync
  class Mailchimp
    AUTH_USER = "ignored"


    def self.request(method, path, body: '')
      begin
        if SolidusMailchimpSync.api_key.blank?
          raise ArgumentError, "Missing required configuration `SolidusMailchimpSync.api_key`"
        end

        url = url(path)
        response = HTTP.basic_auth(user: AUTH_USER, pass: SolidusMailchimpSync.api_key).
                        request(method.to_sym, url, json: body)

        response_hash = JSON.parse(response.body.to_s)

        if response.code != 200
          raise Error.new(
            request_method: method,
            request_url: url,
            request_body: body,

            type: response_hash["type"],
            title: response_hash["title"],
            status: response_hash["status"] || response.code,
            detail: response_hash["detail"],
            instance: response_hash["instance"],

            response_hash: response_hash
          )
        end

        response_hash
      rescue JSON::ParserError => e
        raise Error.new(request_method: method, request_url: url, request_body: body,
                        status: response.status, detail: "JSON::ParserError #{e}",
                        response_body: response.body.to_s)
      end
    end

    # Assumes an ECommerce request to our store, prefixes path argument with
    # `/ecommerce/store/#{SolidusMailchimpSync.store_id}/`
    def self.ecommerce_request(method, path, body: nil, store_id: SolidusMailchimpSync.store_id)
      if store_id.blank?
        raise ArgumentError, "Missing required configuration `SolidusMailchimpSync.store_id`"
      end

      path = "/ecommerce/stores/#{store_id}/" + path.sub(%r{\A/}, '')
      request(method, path, body: body)
    end


    def self.base_url
      "https://#{SolidusMailchimpSync.data_center}.api.mailchimp.com/3.0/"
    end

    def self.url(path)
      base_url + path.sub(%r{\A/}, '')
    end

  end
end
