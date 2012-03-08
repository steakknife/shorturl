require 'rake'
require 'rdoc/task'
require 'rake/testtask'

task :default => [ :test, :doc ]


### Tests

desc "Run the tests"
Rake::TestTask.new("test") do |t|
  t.pattern = "test/**/ts_*.rb"
  t.verbose = true
end


### Documentation

desc "Write the documentation"
Rake::RDocTask.new("doc") do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.title = "ShortURL Documentation"
#  rdoc.options << "--line-numbers --inline-source"
  %w(README TODO MIT-LICENSE ChangeLog Lib/*.rb).each do |glob|
    rdoc.rdoc_files.include(glob)
  end

  rdoc.rdoc_files.exclude("test/*")
end


desc "Upload documentation to RubyForge"
task :upload_doc do
  sh "scp -r doc/* robbyrussell@rubyforge.org:/var/www/gforge-projects/shorturl"
end



### Stats

desc "Statistics for the code"
task :stats do
  begin
    require "code_statistics"
    CodeStatistics.new(%w(Code lib), %w(Units test)).to_s
  rescue LoadError
    puts "Couldn't load code_statistics (install rails)"
  end
end
