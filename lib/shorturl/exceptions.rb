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

      def self.throw(exception)
        unless exception.is_a? ShortUrlExceptions
          puts "Warning: What kind of garbage is this? #{exception.class}" 
        end
        @@exception_dumpster << exception
      end

      def self.pop
        @@exception_dumpster.pop
      end

      def self.top
        @@exception_dumpster.last
      end

      def self.got_junk?
        ! @@exception_dumpster.empty?
      end

      def self.empty?
        @@exception_dumpster.empty?
      end

      def self.each
        @@exception_dumpster.each
      end

    end # Dumpster
  end # Exceptions
end # ShortUrl
