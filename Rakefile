$KCODE = 'UTF-8'

$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'rubygems'
require 'rake/testtask'
require "sdoc_site/automation"

task :default => :test

desc "Run tests"
Rake::TestTask.new("test") do |t|
  t.libs << 'tests'
  t.pattern = 'tests/**/*_test.rb'
  t.warning = true
  t.verbose = true
end

desc "Generate sdoc for all new versions"
task :build_new_docs do
  a = SDocSite::Automation.new File.expand_path(File.join('.', 'public', 'doc')), {:debug => 1}
  a.build_new_docs
  a.clean_up
end


# `~/code/sdoc/bin/sdoc -N -o rdoc -x irb/output-method.rb -x ext/win32ole/tests/ -x ext/win32ole/sample/ README *.c *.h lib/ ext/`