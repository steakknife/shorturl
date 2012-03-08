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
    end

      # Inner service block(s)
      def service(service_description)
        hostname = service_description.values[0]
        @@current_service = @@services[service_description.keys[0]] = ::ShortUrl::Service.new(hostname) 
        yield
        show_missing_token_help
        # End the previously current service block
        @@current_service = nil
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

        def param(_params)
          @@current_service.params.merge!(_params)
        end

        def params(_params)
          @@current_service.params.merge!(_params)
        end

        def header(_headers)
          @@current_service.headers.merge!(_headers)
        end

        def headers(_headers)
          @@current_service.headers.merge!(_headers)
        end

        def request_body(&block)
           @@current_service.request_body_block = lambda(&block)
        end

        def response(&block)
           @@current_service.response_block = lambda(&block)
        end

        def response_body(&block)
           @@current_service.response_body_block = lambda(&block)
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

        def show_missing_token_help
          if @@current_service.missing_token_help and ! @@current_service.exception_thrown.empty?
            @@current_service.exception_thrown.empty.each do |e|
              puts "#{e.class} #{e.message}"
            end
            puts
            puts @@current_service.missing_token_help
            raise @@current_service.exception_thrown.last
          end
        end
  private
    

    @@current_service = nil
  end 
end
