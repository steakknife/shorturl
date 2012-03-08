module ShortUrl
  module Tokens
    TOKENS_FILENAME = File.join(ENV['HOME'],'.shorturl')
    @@tokens = nil
    @@exception_dumpster = []

    def tokens
      return @@tokens unless @@tokens.nil?
      begin
        if @@exception_dumpster.empty?
          require 'yaml'
          @@tokens = YAML.load(File.read(TOKENS_FILENAME)) if @@tokens.nil?
        else
          @@tokens = {}
        end
      rescue SyntaxError => e
        @@exception_dumpster << TokenLoadError.new("Syntax error in #{TOKENS_FILENAME}: #{e.message}.")
        puts "retrying" 
        retry

      rescue Errno::EACCES
        @@exception_dumpster << TokenLoadError.new("Permissions prevent reading token file #{TOKENS_FILENAME}.")
        puts "retrying" 
        retry

      rescue Errno::ENOENT
        @@exception_dumpster << TokenLoadError.new("YAML token file #{TOKENS_FILENAME} was not found.")
        puts "retrying" 
        retry

      rescue LoadError
        @@exception_dumpster = TokenLoadError.new('YAML gem did not load successsfully.  Try "gem install psych".')
        puts "retrying" 
        retry

      rescue Exception => f
        @@exception_dumpster = TokenLoadError.new("Other exception: #{f.message}.")
        puts "retrying" 
        retry

      end

      @@tokens
    end
  end
end
