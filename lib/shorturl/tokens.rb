module ShortUrl
  module Tokens
    TOKENS_FILENAME = File.join(ENV['HOME'],'.shorturl')
    @@tokens = nil
    @@exception_thrown = []

    def tokens
      return @@tokens unless @@tokens.nil?
      begin
        if @@exception_thrown.empty?
          require 'yaml'
          @@tokens = YAML.load(File.read(TOKENS_FILENAME)) if @@tokens.nil?
        else
          @@tokens = {}
        end
      rescue SyntaxError => e
        @@exception_thrown << TokenLoadError.new("Syntax error in #{TOKENS_FILENAME}: #{e.message}.")
        puts "retrying" 
        retry

      rescue Errno::EACCES
        @@exception_thrown << TokenLoadError.new("Permissions prevent reading token file #{TOKENS_FILENAME}.")
        puts "retrying" 
        retry

      rescue Errno::ENOENT
        @@exception_thrown << TokenLoadError.new("YAML token file #{TOKENS_FILENAME} was not found.")
        puts "retrying" 
        retry

      rescue LoadError
        @@exception_thrown = TokenLoadError.new('YAML gem did not load successsfully.  Try "gem install psych".')
        puts "retrying" 
        retry

      rescue Exception => f
        @@exception_thrown = TokenLoadError.new("Other exception: #{f.message}.")
        puts "retrying" 
        retry

      end

      @@tokens
    end
  end
end
