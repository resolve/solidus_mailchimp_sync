require 'json'
require 'http'
require 'solidus_mailchimp_sync'

module SolidusMailchimpSync
  class Mailchimp
    AUTH_USER = "ignored"

    # If Mailchimp errors, will normally raise a SolidusMailchimpSync::Error, but
    # set `return_errors: true` to return the Error as return value instead.
    def self.request(method, path, body: nil, return_errors: false)
      if SolidusMailchimpSync.api_key.blank?
        raise ArgumentError, "Missing required configuration `SolidusMailchimpSync.api_key`"
      end

      url = url(path)
      args = [method.to_sym, url]
      args << { json: body } if body
      response = HTTP.basic_auth(user: AUTH_USER, pass: SolidusMailchimpSync.api_key).
                      request(*args)

      response_hash = response.body.present? ? JSON.parse(response.body.to_s) : { status: response.code }

      unless (200..299).cover?(response.code)
        return Error.new(
          request_method: method,
          request_url: url,
          request_body: body,

          type: response_hash["type"],
          title: response_hash["title"],
          status: response_hash["status"] || response.code,
          detail: response_hash["detail"],
          instance: response_hash["instance"],

          response_hash: response_hash
        ).tap { |error| raise error unless return_errors }
      end

      response_hash
    rescue JSON::ParserError => e
      return Error.new(request_method: method, request_url: url, request_body: body,
                      status: response.status, detail: "JSON::ParserError #{e}",
                      response_body: response.body.to_s).tap { |error| raise error unless return_errors }
    end

    # Assumes an ECommerce request to our store, prefixes path argument with
    # `/ecommerce/store/#{SolidusMailchimpSync.store_id}/`
    def self.ecommerce_request(method, path, body: nil, store_id: SolidusMailchimpSync.store_id, return_errors: false)
      if store_id.blank?
        raise ArgumentError, "Missing required configuration `SolidusMailchimpSync.store_id`"
      end

      path = "/ecommerce/stores/#{store_id}/" + path.sub(%r{\A/}, '')
      request(method, path, body: body, return_errors: return_errors)
    end

    def self.base_url
      "https://#{SolidusMailchimpSync.data_center}.api.mailchimp.com/3.0/"
    end

    def self.url(path)
      base_url + path.sub(%r{\A/}, '')
    end

  end
end
