# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rubygems'
require 'shorturl/version'

SPEC = Gem::Specification.new do |s|
  s.name              = "shorturl"
  s.version           = ShortUrl::VERSION
  s.author            = "Robby Russell"
  s.summary           = "Shorten URLs using any of various shortening services."
  s.email             = "robby@planetargon.com"
  s.homepage          = "http://github.com/robbyrussell/shorturl/"
  s.platform          = Gem::Platform::RUBY
  s.rubyforge_project = 'shorturl'
  s.description       = <<-desc
  ShortURL is a very simple library and command to use URL
  shortening services such as is.gd, git.io, and TinyURL.
  desc

  s.required_rubygems_version = '>= 1.3.6'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'

  candidates            = Dir["{bin,lib,doc,test,examples}/**/*"]
  s.files               = candidates
  s.require_path        = "lib"
  s.autorequire         = "shorturl"
  s.test_file           = "test/ts_all.rb"
  s.has_rdoc            = true
  s.extra_rdoc_files    = %w(README TODO MIT-LICENSE ChangeLog)
  s.rdoc_options        = %w(--title ShortURL Documentation --main README -S -N --all)
  s.default_executable  = "shorturl"
  s.executables         = %w(shorturl)
end
