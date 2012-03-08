# shorturl.rb
#
#   Created by Vincent Foley on 2005-06-02
#   Heavily refactored by Barry Allard

require 'shorturl/dsl'
require 'shorturl/tokens'

module ShortURL
   extend ::ShortUrl::DSL
  include ::ShortUrl::DSL
  extend ::ShortUrl::Tokens

  ##

  @@exception_thrown = []

  ## 

  shorturl do

    service :tinyurl => 'tinyurl.com' do
      action '/api-create.php'
      field  'website_url' 

      response_body do |body|
        URI.extract(body).grep(/tinyurl/)[0] 
      end
    end

    service :shorl => 'shorl.com' do
      action '/create.php'

      response_body  do |body|
        URI.extract(body)[2] 
      end
    end

      # SnipURL offers a restful HTTP API but it cannot be used without
      # registration.
    service :snipurl => 'snipurl.com' do
      action '/site/index'
      field  'url'

      response_body do |body|
        URI.extract(body).grep(/http:\/\/snipurl.com/)[0] 
      end
    end 

    service :metamark => 'metamark.net' do
      action '/add'
      field  'long_url'

      response_body  do |body| 
        URI.extract(body).grep(/xrl.us/)[0] 
      end 
    end

    service :minilink => 'minilink.org' do
      method :get

      response_body do |body|
        URI.extract(body)[-1] 
      end
    end

    service :lns => 'ln-s.net' do
      method :get
      action '/home/api.jsp'

      response_body  do |body|
        URI.extract(body)[0] 
      end
    end

    service :shiturl => 'shiturl.com' do
      method :get
      action '/make.php'

      response_body  do |body|
        URI.extract(body).grep(/shiturl/)[0] 
      end
    end

      
    service :moourl => 'moourl.com' do
      action '/create/'
      method :get      
      field  'source'

      code   302
      response do |res|
        'http://moourl.com/' + res['location'].match(/\?moo=/).post_match
      end
    end 

    service :bitly => 'api-ssl.bitly.com' do
      method :get
      ssl    
      action '/v3/shorten/'
      field 'longUrl'
      param 'format' => 'txt'
      param 'login'  => tokens()['bitly']['username']
      param 'apiKey' => tokens()['bitly']['key']

      response_body  do |body|
        body
      end

      missing_token_text <<-EOS
      Bit.ly requires a token.  
     
      Two painfree steps to get this.

          1) Get yours easily right now from: 


                 http://bitly.com/a/your_api_key


          2) Save both parts in a file ~/.shorturl similar to this YAML template:

           
                 bitly:
                   username: O_adsfasdfasfasfd
                   key: R_afasdfasdfasdf


      You're done!  Have a martini.

      Cheers.
      EOS

    end
      

    service :ur1 => 'ur1.ca' do
      method :post
      action '/'
      field  'longurl'

      response_body  do |body|
        URI.extract(body).grep(/ur1/)[0] 
      end
    end

    service :vurl => 'vurl.me' do
      method :get
      action '/shorten'
      field  'url'

      response_body  do |body|
        body
      end
    end 

    service :isgd => 'is.gd' do
      method :get
      action '/api.php'
      field  'longurl'

      response_body  do |body|
        body
      end
    end

    service :gitio => 'git.io' do
      method :post
      action '/'
      field  'url' 

      code   201
      response do |res|
        res['location']
      end
    end

    service :googl => 'www.googleapis.com' do
      ssl
      method :post
      action '/urlshortener/v1/url'

      request_body do |long_url|
        [ 'application/json', "{\"longUrl\": \"#{long_url}\"}" ]
      end 

      response_body do |body|
        body.split('"').grep(/goo\.gl/)[0]
      end
    end
  end # shorturl

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

  def self.help_texts
    return {}.tap do |result|
      @@valid_services.each do |k, v|
        result[k] = v.help.to_s
      end 
    end
  end

  # Main method of ShortURL, its usage is quite simple, just give an
  # url to shorten and an optional service.  If no service is
  # selected, RubyURL.com will be used.  An invalid service symbol
  # will raise an ShortUrl::InvalidService exception.  Missing
  # API tokens/credentials will  raise an  ShortUrl::TokenLoadError
  # exception.
  #
  # Valid +service+ values:
  #
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
  # * <tt>:orz</tt>
  # * <tt>:isgd</tt>
  # * <tt>:googl</tt>
  # * <tt>:gitio</tt>
  #
  # call-seq:
  #   ShortURL.shorten("http://mypage.com") => Uses RubyURL
  #   ShortURL.shorten("http://mypage.com", :tinyurl)
  def self.shorten(url, service = :isgd)
    raise ::ShortUrl::InvalidService unless valid_services.include? service

    @@services[service].call(url).strip
  end

end # module ShortUrl

