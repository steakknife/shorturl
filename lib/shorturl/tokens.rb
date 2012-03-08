module ShortUrl
  module Tokens
    MAX_TRIES       = 3
    TOKENS_FILENAME = File.join(ENV['HOME'], '.shorturl') # ~/.shorturl
  private
    @@tokens        = nil
  public

    def tokens
      return @@tokens unless @@tokens.nil?

      ## @@tokens is nil

      tries = 0 
      begin
        require 'yaml'
        @@tokens = nil
        @@tokens = YAML.load(File.read(TOKENS_FILENAME)) 
      rescue Exception => e
        new_exception_msg = ""
        puts "exception #{e.class} #{e} #{e.message}" 

        { SyntaxError    => 'SyntaxError in %s: %s',
          Errno::EACCES  => 'Permissions prevent reading token file %s.',
          Errno::ENOENT  => 'YAML token file %s was not found.',
          LoadError      => 'YAML gem did not load successsfully.  Try "gem install psych".',
          Exception      => 'Other exception loading file %s: %s'
        }.each do |e_class, msg|
          if e.is_a? e_class
            new_exception = msg % [TOKENS_FILENAME, e.message]
            break
          end
        end

        if (tries += 1) < MAX_TRIES
          puts "retrying #{e.class} #{e} #{e.message}" 
          sleep 1
          retry
        else
          puts "giving up"
          Exceptions::Dumpster.throw( Exceptions::TokenLoadError.new( new_exception_msg ) )
        end
      end
    end
  end # Tokens
end # ShortUrl
