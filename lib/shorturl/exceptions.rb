module ShortUrl
  module Exceptions

    ###

    class ShortUrlExceptions < Exception ; end

    class ServiceNotAvailable < ShortUrlExceptions ; end

    class InvalidService < ShortUrlExceptions ; end

    class TokenLoadError < ShortUrlExceptions ; end


    ###

    module Dumpster
      private
        @@exception_dumpster = []
      public

      def throw(exception)
        unless exception.is_a? ShortUrlExceptions
          puts "Warning: What kind of garbage is this? #{exception.class}" 
        end
        @@exception_dumpster << exception
      end

      def pop
        @@exception_dumpster.pop
      end

      def top
        @@exception_dumpster.last
      end

      def junk?
        ! @@exception_dumpster.empty?
      end

      def empty?
        @@exception_dumpster.empty?
      end

      def each
        @@exception_dumpster.each
      end

    end # Dumpster
  end # Exceptions
end # ShortUrl
