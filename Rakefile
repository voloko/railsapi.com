$KCODE = 'UTF-8'

$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'rake/testtask'
require "sdoc_site/rails_git"
require 'rake/rdoctask'
require 'sdoc/lib/sdoc'
require 'rdoc/rdoc'
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
  options << '--inline-source'
  options << '-A cattr_accessor=object'
  options << '--charset' << 'utf-8'
  rg.in_rails_dir do
    options += file_list
    RDoc::RDoc.new.document(options)
  end
  
  rg.add_generated_version(v)
end
