module SolidusMailchimpSync
  class Error < StandardError
    attr_reader :type, :title, :status, :detail, :instance,
                :request_method, :request_url, :request_body,
                :response_body, :response_hash

    def initialize( type:nil, title:nil, status: nil, detail: nil, instance: nil,
                    request_method:nil, request_url: nil, request_body: nil,
                    response_body: nil, response_hash: nil)

      @type = type
      @title = title
      @status = status
      @detail = detail
      @instance = instance

      @request_method = request_method.to_s.upcase
      @request_url = request_url
      @request_body = request_body

      @response_body = response_body
      @response_hash = response_hash

      super(constructed_message)
    end

    def constructed_message
      errors = response_hash.try {|h| h["errors"] }.to_s.presence
      [status, title, detail, errors].compact.join(': ')
    end
  end
end
