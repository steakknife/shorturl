# shorturl.rb
#
#   Created by Vincent Foley on 2005-06-02
#   Heavily refactored by Barry Allard
#

module ShortUrl
  require 'net/http'
  require 'cgi'
  require 'uri'
  require 'shorturl/exceptions'

  class Service
    attr_accessor :port, :code, :method, :action, :field, :block, :response_block, :ssl, :extra_fields, :extra_headers

    # Intialize the service with a hostname (required parameter) and you
    # can override the default values for the HTTP port, expected HTTP
    # return code, the form method to use, the form action, the form
    # field which contains the long URL, and the block of what to do
    # with the HTML code you get.
    def initialize(hostname) # :yield: service
      @hostname = hostname
      @code = 200
      @method = :post
      @action = '/'
      @field = 'url'
      @ssl = false
      @extra_fields = {}
      @extra_headers = {}

      if block_given?
        yield self
      end
    end

    def query_fields(long_url)
      { @field => long_url }.merge @extra_fields
    end

    def query(long_url)
      query_fields(long_url).collect do |k,v|
        URI.encode(k.to_s) + '=' + URI.encode(v.to_s) 
      end.join '&'
    end

#    def merge_extra_request_headers(request)
#      extra_headers.each do |k,v|
#        request[k] = v
#      end 
#    end

    # Now that our service is set up, call it with all the parameters to
    # (hopefully) return only the shortened URL.
    def call(long_url)
      uri = URI((ssl ? 'https' : 'http') + '://' + @hostname)
      uri.port = @port if @port
      uri.path = @action 
      uri.query = query(long_url) if @method == :get
      uri = URI.parse(URI.encode(uri.to_s)) # normalize uri

      request = case @method
                when :post
                  Net::HTTP::Post
                when :get
                  Net::HTTP::Get
                end.new(uri.request_uri)
      request.set_form_data query_fields(long_url) if @method == :post
      
      unless extra_headers.empty? #      merge_extra_request_headers(request) unless extra_headers.empty?
        extra_headers.merge(request.to_hash)
        request.initialize_http_header(extra_headers) 
      end
           
      Net::HTTP.start(uri.hostname, uri.port,
                      :use_ssl     => ssl,
                      :verify_mode => OpenSSL::SSL::VERIFY_NONE,
                      :scheme      => uri.scheme
      ) { |http|

        response = http.request(request)

        if response.code.to_i == @code
          if @response_block
            @response_block.call(response)
          else
            @block.call(response.read_body)
          end
        end
      }
    rescue Errno::ECONNRESET => e
      raise ::ShortUrl::ServiceNotAvailable, e.to_s, e.backtrace
    end
  end
end
