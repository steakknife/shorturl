# shorturl.rb
#
#   Created by Vincent Foley on 2005-06-02
#   Heavily refactored by Barry Allard

require 'shorturl/dsl'

module ShortURL
  extend ::ShortUrl::DSL
  include ::ShortUrl::DSL

  TOKENS_FILENAME = File.join(ENV['HOME'],'.shorturl')
  @@tokens = nil

  def self.tokens
    require 'yaml'
    @@tokens = YAML.load(File.read(TOKENS_FILENAME)) if @@tokens.nil?
    @@tokens
  end

  def self.bitly_username
    tokens()['bitly']['username']
  end

  def self.bitly_key
    tokens()['bitly']['key']
  end

  ## 

  shorturl do

    service :rubyurl => 'rubyurl.com' do
      action '/rubyurl/remote'
      field  'website_url'

      block  do |body|
        URI.extract(body).grep(/rubyurl/)[0]
      end
    end
    
    service :tinyurl => 'tinyurl.com' do
      action '/api-create.php'
      field  'website_url' 

      block  do |body|
        URI.extract(body).grep(/tinyurl/)[0] 
      end

    end
    service :shorl => 'shorl.com' do
      action '/create.php'

      block  do |body|
        URI.extract(body)[2] 
      end
    end

      # SnipURL offers a restful HTTP API but it cannot be used without
      # registration.
    service :snipurl => 'snipurl.com' do
      action '/site/index'
      field  'url'

      block  do |body|
        URI.extract(body).grep(/http:\/\/snipurl.com/)[0] 
      end
    end 

    service :metamark => 'metamark.net' do
      action '/add'
      field  'long_url'

      block  do |body| 
        URI.extract(body).grep(/xrl.us/)[0] 
      end 
    end

    service :minilink => 'minilink.org' do
      method :get

      block  do |body|
        URI.extract(body)[-1] 
      end
    end

    service :lns => 'ln-s.net' do
      method :get
      action '/home/api.jsp'

      block  do |body|
        URI.extract(body)[0] 
      end
    end

    service :shiturl => 'shiturl.com' do
      method :get
      action '/make.php'

      block  do |body|
        URI.extract(body).grep(/shiturl/)[0] 
      end
    end

    service :shortify => 'shortify.wikinote.com' do
      method :get
      action '/shorten.php'

      block  do |body|
        URI.extract(body).grep(/shortify/)[-1] 
      end
    end
      
    service :moourl => 'moourl.com' do
      action '/create/'
      method :get      
      field  'source'

      code   302
      response_block do |res|
        'http://moourl.com/' + res['location'].match(/\?moo=/).post_match
      end
    end 

    service :bitly => 'api-ssl.bitly.com' do
      method :get
      ssl    
      action '/v3/shorten/'
      field  'longUrl'
      extra_field 'format' => 'txt'
      extra_field 'login'  => bitly_username
      extra_field 'apiKey' => bitly_key

      block  do |body|
        body
      end
    end
      

    service :ur1 => 'ur1.ca' do
      method :post
      action '/'
      field  'longurl'

      block  do |body|
        URI.extract(body).grep(/ur1/)[0] 
      end
    end

    service :vurl => 'vurl.me' do
      method :get
      action '/shorten'
      field  'url'

      block  do |body|
        body
      end
    end 

    service :isgd => 'is.gd' do
      method :get
      action '/api.php'
      field  'longurl'

      block  do |body|
        body
      end
    end

    service :gitio => 'git.io' do
      method :post
      action '/'
      field  'url' 

      code   201
      response_block do |res|
        res['location']
      end
    end

  end
    # :skinnylink => 'skinnylink.com") { |s|
    #   block do |body| URI.extract(body).grep(/skinnylink/)[0] }
    # },

    # :linktrim => 'linktrim.com") { |s|
    #   method :get
    #   action "/lt/generate"
    #   block do |body| URI.extract(body).grep(/\/linktrim/)[1] }
    # },

    # :shorterlink => 'shorterlink.com") { |s|
    #   method :get
    #   action "/add_url.html"
    #   block do |body| URI.extract(body).grep(/shorterlink/)[0] }
    # },

    # :fyad => 'fyad.org") { |s|
    #   method :get
    #   block do |body| URI.extract(body).grep(/fyad.org/)[2] }
    # },

    # :d62 => 'd62.net") { |s|
    #   method :get
    #   block do |body| URI.extract(body)[0] }
    # },

    # :littlink => 'littlink.com") { |s|
    #   block do |body| URI.extract(body).grep(/littlink/)[0] }
    # },

    # :clipurl => 'clipurl.com") { |s|
    #   action "/create.asp"
    #   block do |body| URI.extract(body).grep(/clipurl/)[0] }
    # },

    # :orz => '0rz.net") { |s|
    #   action "/create.php"
    #   block do |body| URI.extract(body).grep(/0rz/)[0] }
    # },

    # :urltea => 'urltea.com") { |s|
    #   method :get
    #   action "/create/"
    #   block do |body| URI.extract(body).grep(/urltea/)[6] }
    # }

  # Array containing symbols representing all the implemented URL
  # shortening services

  # Returns @@valid_services
  def self.valid_services
    @@valid_services = @@services.keys if @@valid_services.nil?
    @@valid_services 
  end

  # Main method of ShortURL, its usage is quite simple, just give an
  # url to shorten and an optional service.  If no service is
  # selected, RubyURL.com will be used.  An invalid service symbol
  # will raise an ArgumentError exception
  #
  # Valid +service+ values:
  #
  # * <tt>:rubyurl</tt>
  # * <tt>:tinyurl</tt>
  # * <tt>:shorl</tt>
  # * <tt>:snipurl</tt>
  # * <tt>:metamark</tt>
  # * <tt>:makeashorterlink</tt>
  # * <tt>:skinnylink</tt>
  # * <tt>:linktrim</tt>
  # * <tt>:shorterlink</tt>
  # * <tt>:minlink</tt>
  # * <tt>:lns</tt>
  # * <tt>:fyad</tt>
  # * <tt>:d62</tt>
  # * <tt>:shiturl</tt>
  # * <tt>:littlink</tt>
  # * <tt>:clipurl</tt>
  # * <tt>:shortify</tt>
  # * <tt>:orz</tt>
  # * <tt>:isgd</tt>
  #
  # call-seq:
  #   ShortURL.shorten("http://mypage.com") => Uses RubyURL
  #   ShortURL.shorten("http://mypage.com", :tinyurl)
  def self.shorten(url, service = :rubyurl)
    if valid_services.include? service
      @@services[service].call(url)
    else
      raise ::ShortUrl::InvalidService
    end
  end

end

