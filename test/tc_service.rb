# tc_service.rb
#
#   Created by Vincent Foley on 2005-06-01

$test_lib_dir = File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift($test_lib_dir)

require 'test/unit'
require 'shorturl'


class TestService < Test::Unit::TestCase

  def test_call
    service = ::ShortUrl::Service.new("oasdasobf")
    assert_raise(SocketError) { service.call(nil) }

    service = ::ShortUrl::Service.new("tinyurl.com") { |s|
      s.code = 404
      s.action = "/create.php"
      s.block = lambda { |body|
        URI.extract(body).grep(/tinyurl/)[-1]
      }
    }
    assert_nil service.call("http://www.google.com")
  end
  
  def test_initialize
    service = ::ShortUrl::Service.new("is.gd")
    assert_equal(service.port, 80)
    assert_equal(service.code, 200)
    assert_equal(service.method, :post)
    assert_equal(service.action, "/")
    assert_equal(service.field, "url")

    service = ::ShortUrl::Service.new("is.gd") { |s|
      s.port = 8080
      s.code = 302
      s.method = :get
      s.action = "/create.php"
      s.field = "link"
    }
    assert_equal(service.port, 8080)
    assert_equal(service.code, 302)
    assert_equal(service.method, :get)
    assert_equal(service.action, "/create.php")
    assert_equal(service.field, "link")
  end
  
end
