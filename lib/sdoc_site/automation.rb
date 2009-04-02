require "fileutils"
require "sdoc"

require "sdoc_site/builds"

class SDocSite::Automation
  def initialize public_dir, options = {}
    @public_dir = public_dir
    @options = options
    
    name = 'sdoc_' + rand.to_s.gsub(/\D/, '')
    @temp_root = File.join('/tmp', 'sdoc')
    clean_up
    FileUtils.mkdir_p @temp_root
    
    require "sdoc_site/automation/rails"
    require "sdoc_site/automation/haml"
    require "sdoc_site/automation/hpricot"
    require "sdoc_site/automation/nokogiri"
    require "sdoc_site/automation/rack"
    require "sdoc_site/automation/rspec"
    require "sdoc_site/automation/sinatra"
    @automations = []
    @automations << SDocSite::Automation::Rails.new(self)
    @automations << SDocSite::Automation::Haml.new(self)
    @automations << SDocSite::Automation::Hpricot.new(self)
    @automations << SDocSite::Automation::Nokogiri.new(self)
    @automations << SDocSite::Automation::Rack.new(self)
    @automations << SDocSite::Automation::RSpec.new(self)
    @automations << SDocSite::Automation::Sinatra.new(self)
    
    @builds = SDocSite::Builds.new @public_dir
    @builds_map = {}
    @builds.simple_builds.each{ |build| @builds_map[build.name] = build }
  end
  
  def build_new_docs
    @automations.each do |auto|
      
      debug_msg "Working with #{auto.short_name}"
      build = @builds_map[auto.short_name]
      versions_to_build = []
      debug_msg " fetching available verions"
      if build
        max_build_version = build.versions.max
        versions_to_build += auto.available_versions.select{|v| v > max_build_version}
      else
        versions_to_build << auto.available_versions.max
      end
      
      if versions_to_build.size > 0
        debug_msg " version to build #{versions_to_build.join(' ')}"
      else
        debug_msg " nothing to build"
      end
      versions_to_build.each do |version|
        build_version auto, version
      end
      
      debug_msg ""
    end
  end
  
  def build_version auto, version
    debug_msg " building doc"
    doc_dir = auto.build_doc version
    
    debug_msg " preparing for web (gzip)"
    prepare doc_dir
    
    target = File.join(@public_dir, "#{auto.short_name}-v#{version.to_s}") 
    debug_msg " copying #{doc_dir} to #{target}"
    FileUtils.cp_r File.join(doc_dir, '.'), target 
  end
  
  def prepare doc_dir
    
  end
  
  def temp_dir
    name = 'tmp_' + rand.to_s.gsub(/\D/, '')
    File.join(@temp_root, name)
  end
  
  def clean_up
    FileUtils.rm_rf @temp_root
  end
  
  def debug_msg msg
    puts msg if @options[:debug]
  end
end