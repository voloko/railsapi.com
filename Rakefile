$KCODE = 'UTF-8'

$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'rubygems'
require 'rake/testtask'
require "sdoc_site/rails_git"
require 'rake/rdoctask'
require 'sdoc'
require 'fileutils'

task :default => :test

desc "Get all rails tags"
task :rails_versions do
  rg = SDocSite::RailsGit.new('rails')
  p rg.all_versions.map { |v| v.to_s }
end

Rake::TestTask.new("test") do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
  t.verbose = true
end

desc "Generate sdoc for rails version"
task :doc_for_version do
  rg = SDocSite::RailsGit.new('rails')
  v = ENV['version']
  if v.nil?
    v = rg.all_versions.last
  else
    v = SDocSite::Version.new(v)
  end
  rg.co_version(v)
  file_list = Rake::FileList.new
  rg.extract_rdoc_includes.each {|i| file_list.include(i) }
  rg.extract_rdoc_excludes.each {|i| file_list.exclude(i) }
  path = File.expand_path("public/doc/#{v.to_tag}")
  if File.exists? path
    FileUtils.rm_rf path
  end
  
  options = []
  options << "-o" << path
  options << "--title" << "Ruby on Rails Documentation"
  options << '--line-numbers' 
  options << '--charset' << 'utf-8'
  
  rg.in_rails_dir do
    FileUtils.cp 'railties/README', './README'
    options << './README'
    options += file_list
    p options
    RDoc::RDoc.new.document(options)
    FileUtils.rm './README'
  end
  
  `zip -r public/doc/#{v.to_tag}/rdoc public/doc/#{v.to_tag}/`
  rg.add_generated_version(v)
end

task :add_generated_version do 
  rg = SDocSite::RailsGit.new('rails')
  v = ENV['version']
  if v.nil?
    v = rg.all_versions.last
  else
    v = SDocSite::Version.new(v)
  end
  rg.add_generated_version(v)
end


`~/code/sdoc/bin/sdoc -N -o rdoc -x irb/output-method.rb -x ext/win32ole/tests/ -x ext/win32ole/sample/ README *.c *.h lib/ ext/`