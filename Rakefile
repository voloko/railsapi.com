$KCODE = 'UTF-8' unless RUBY_VERSION >= '1.9'

$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'rubygems'
require 'rake/testtask'
require "sdoc_site/automation"

task :default => :test

desc "Run tests"
Rake::TestTask.new("test") do |t|
  t.libs << 'tests'
  t.pattern = 'tests/**/*_test.rb'
  # t.warning = true
  # t.verbose = true
end

desc "Generate sdoc for all new versions"
task :build_new_docs do
  a = SDocSite::Automation.new File.expand_path(File.join('.', 'public', 'doc')), {:debug => 1}
  a.build_new_docs
  a.generate_index
end

desc "Rebuild sdoc for ENV[name], ENV[version]"
task :rebuild_version do
  a = SDocSite::Automation.new File.expand_path(File.join('.', 'public', 'doc')), {:debug => 1}
  a.rebuild_version ENV["name"], ENV["version"]
  a.generate_index
end

desc "Generate index.html"
task :generate_index do
  a = SDocSite::Automation.new File.expand_path(File.join('.', 'public', 'doc')), {:debug => 1}
  a.generate_index
end

desc "Merges ENV[builds]"
task :merge_builds do
  a = SDocSite::Automation.new File.expand_path(File.join('.', 'public', 'doc')), {:debug => 1}
  a.merge_builds SDocSite::Builds::MergedBuild.from_str(ENV["builds"])
  a.generate_index
end

desc "Remerge all merged builds"
task :remerge_all_builds do
  builds = SDocSite::Builds::List.new File.join('.', 'public', 'doc')
  a = SDocSite::Automation.new File.expand_path(File.join('.', 'public', 'doc')), {:debug => 1}
  builds.merged_builds.each do |build|
    begin
      ENV['builds'] = build.to_s
      puts `rake merge_builds`
      # a.merge_builds build
      # a.generate_index
      # GC.start
    rescue Exception => e
      puts e.to_s
      puts e.backtrace.to_s
    end
  end
end

desc "Cleanup oldies"
task :cleanup_oldies do
  a = SDocSite::Automation.new File.expand_path(File.join('.', 'public', 'doc')), {:debug => 1}
  a.cleanup_oldies
  a.generate_index
end

desc "Remerge all merged builds"
task :rebuild_all_docs do
  builds = SDocSite::Builds::List.new File.join('.', 'public', 'doc')
  a = SDocSite::Automation.new File.expand_path(File.join('.', 'public', 'doc')), {:debug => 1}
  builds.simple_builds.each do |build|
    build.versions.each do |version|
      begin
        ENV['name'] = build.name
        ENV['version'] = version.to_s
        puts `rake rebuild_version`
        # a.rebuild_version build.name, version.to_s
        # a.generate_index
        # GC.start
      rescue Exception => e
        puts e.to_s
        puts e.backtrace.to_s
      end
    end
  end
end
# `~/code/sdoc/bin/sdoc -N -o rdoc -x irb/output-method.rb -x ext/win32ole/tests/ -x ext/win32ole/sample/ README *.c *.h lib/ ext/`