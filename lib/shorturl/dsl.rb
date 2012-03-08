# shorturl/dsl.rb
#
#   Barry Allard 
#

require 'shorturl/service'

module ShortUrl
  module DSL
    # Outer shorturls block
    def shorturl
      @@current_service = nil
      @@valid_services = nil
      @@services = {}
      yield
      @@current_service = nil
    end

      # Inner service block(s)
      def service(service_description)
        hostname = service_description.values[0]
        @@current_service = @@services[service_description.keys[0]] = ::ShortUrl::Service.new(hostname) 
        yield
      end

        # Service fields
        def action(_action)
          @@current_service.action = _action
        end

        def method(_method)
          @@current_service.method = _method
        end

        def ssl(_ssl = true)
          @@current_service.ssl = _ssl
        end

        def port(_port)
          @@current_service.port = _port
        end

        def field(_field)
          @@current_service.field = _field
        end

        def extra_field(_extra_fields)
          _extra_fields.each do |k, v|
          end
          @@current_service.extra_fields.merge!(_extra_fields)
        end

        def block(&block)
           @@current_service.block = lambda(&block) if block_given?
        end

        def response_block(&block)
           @@current_service.response_block = lambda(&block) if block_given?
        end

        def code(_code)
          @@current_service.code = _code
        end

        def missing_token_help(_missing_token_help)
          @@current_service.missing_token_help = _missing_token_help
        end

        def help(_help)
          @@current_service._help = _help
        end

  private
    @@current_service = nil
  end 
end
