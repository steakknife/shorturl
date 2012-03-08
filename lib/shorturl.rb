# shorturl.rb
#
#   Created by Vincent Foley on 2005-06-02
#   Heavily refactored by Barry Allard

require 'shorturl/version'
require 'shorturl/dsl'
require 'shorturl/tokens'

module ShortURL
   extend ::ShortUrl::Tokens
  include ::ShortUrl::Tokens
   extend ::ShortUrl::DSL
  include ::ShortUrl::DSL

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


    service :gitio => 'git.io' do
      method :post
      action '/'
      field  'url' 

      code   201
      response do |res|
        res['location']
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

      
    service :moourl => 'moourl.com' do
      action '/create/'
      method :get      
      field  'source'

      code   302
      response do |res|
        'http://moourl.com/' + res['location'].match(/\?moo=/).post_match
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

      missing_token_help <<-EOS
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


    service :isgd => 'is.gd' do
      method :get
      action '/api.php'
      field  'longurl'

      response_body  do |body|
        body
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
  # * <tt>:gitio</tt>
  # * <tt>:minlink</tt>
  # * <tt>:lns</tt>
  # * <tt>:clipurl</tt>
  # * <tt>:orz</tt>
  # * <tt>:isgd</tt>
  # * <tt>:googl</tt>
  #
  # call-seq:
  #   ShortURL.shorten("http://mypage.com") => Uses RubyURL
  #   ShortURL.shorten("http://mypage.com", :tinyurl)
  def self.shorten(url, service = :isgd)
    raise ::ShortUrl::InvalidService unless valid_services.include? service

    @@services[service].call(url).strip
  end

end # module ShortUrl

