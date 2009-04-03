require "fileutils"
require "pathname"
require "sdoc"
require "rubygems"
require "haml"

require "sdoc_site/builds"

class SDocSite::Automation
  def initialize public_dir, options = {}
    @public_dir = public_dir
    @options = options
    
    name = 'sdoc_' + rand.to_s.gsub(/\D/, '')
    @temp_root = File.join('/tmp', 'sdoc')
    
    require "sdoc_site/automation/ruby"
    require "sdoc_site/automation/rails"
    require "sdoc_site/automation/haml"
    require "sdoc_site/automation/hpricot"
    require "sdoc_site/automation/nokogiri"
    require "sdoc_site/automation/rack"
    require "sdoc_site/automation/rspec"
    require "sdoc_site/automation/sinatra"
    @automations = []
    @automations << SDocSite::Automation::Ruby.new(self)
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
  
  # For each automation fetches new version from git/svn
  # compares them with builded versions
  # Builds doc if new ones are available.
  def build_new_docs
    FileUtils.mkdir_p @temp_root
    
    @automations.each do |auto|
      
      debug_msg "Working with #{auto.short_name}"
      build = @builds_map[auto.short_name]
      versions_to_build = []
      debug_msg " fetching available verions"
      if build
        max_build_version = build.versions.max
        versions_to_build += auto.available_versions.select{|v| v > max_build_version}
      else
        n = (auto.respond_to? :versions_to_build) ? auto.versions_to_build : 1
        versions_to_build += auto.available_versions.sort[-n..-1]
      end
      
      if versions_to_build.size > 0
        debug_msg " versions to build: #{versions_to_build.join(', ')}"
      else
        debug_msg " nothing to build"
      end
      versions_to_build.each do |version|
        build_version auto, version
      end
      
      debug_msg ""
    end
    
    clean_up
  end
  
  
  # Rebuild documentation with automation +name+ for +version+
  def rebuild_version name, version
    auto = automation_by_name(name)
    if auto
      build_version auto, SDocSite::Version.new(version)
    else
      debug_msg "Can't find automation for #{name}"
    end
    # clean_up
  end
  
  # Merges given builds with sdoc-merge
  def merge_builds merged_build
    require "sdoc/merge"
    tmp = temp_dir
    target = File.join @public_dir, merged_build.to_s
    
    title = merged_build.builds.map do |build| 
      automation_by_name(build.name).name + " v#{build.version}"
    end.join(', ')
    names = merged_build.builds.map do |build| 
      automation_by_name(build.name).short_name
    end.join(',')
    options = []
    options << "-o" << tmp
    options << '--title' << title
    options << '--names' << names
    merged_build.builds.each do |build|
      options << File.join(@public_dir, build.to_s)
    end
    SDoc::Merge.new.merge(options)
  
    prepare tmp
    
    FileUtils.cp_r File.join(tmp, '.'), target, :remove_destination => true, :preserve => true 
    clean_up
  end
  
  # Creates ziped packaged for doc in +doc_dir+
  def prepare doc_dir
    debug_msg " preparing for web (gzip)"
    zip_file = File.join doc_dir, 'rdoc.zip'
    `zip -r #{zip_file} #{doc_dir}`
  end
  
  # Regenerates index.html
  def generate_index
    @template = Pathname.new(File.dirname(__FILE__)) + 'template' + 'index.haml'
    @outfile = File.join @public_dir, '..', 'index.html'
    engine = ::Haml::Engine.new @template.read
    File.open(@outfile, 'w') do |f|
      f.print engine.render(nil, {
        :version_script => version_script,
        :ruby_version => @builds_map['ruby'].version.to_tag,
        :rails_version => @builds_map['rails'].version.to_tag,
        :rails_size => sizes_hash[@builds_map['rails'].to_s]
      })
    end
  end
  
  # Get automation by short +name+
  def automation_by_name name
    @automations.find {|a| a.short_name == name }
  end
  
  # Unique temporary directory name
  def temp_dir
    name = 'tmp_' + rand.to_s.gsub(/\D/, '')
    File.join(@temp_root, name)
  end
  
  # Cleans all temp dirs
  def clean_up
    FileUtils.rm_rf @temp_root
  end
  
  # Outputs a +msg+ if debug is on
  def debug_msg msg
    puts msg if @options[:debug]
  end
  
protected
  def build_version auto, version
    debug_msg " downloading source and building doc"
    doc_dir = auto.build_doc version
  
    prepare doc_dir
  
    target = File.join(@public_dir, "#{auto.short_name}-v#{version.to_s}") 
    debug_msg " copying #{doc_dir} to #{target}"
    FileUtils.rm_rf target if File.exists? target
    FileUtils.cp_r File.join(doc_dir, '.'), target, :remove_destination => true, :preserve => true 
  end
  
  def version_script
    "versions = #{version_hash.to_json}; sizes = #{sizes_hash.to_json};"
  end
  
  def in_mb(bytes)
    ((bytes / 1024.0 / 1024.0 * 100).round / 100.0).to_s + " Mb"
  end

  def sizes_hash
    result = {}
    @builds.simple_builds.each do |build|
      build.versions.each do |version|
        name = "#{build.name}-#{version.to_tag}"
        file = File.join(@public_dir, name, 'rdoc.zip')
        if File.exists? file
          size = File.stat(file).size
          result[name] = in_mb(size)
        end
      end
    end
    @builds.merged_builds.each do |merged|
      name = merged.builds.map {|build| "#{build.name}-#{build.versions.first.to_tag}"}.join('_')
      file = File.join(@public_dir, name, 'rdoc.zip')
      if File.exists? file
        size = File.stat(file).size
        result[name] = in_mb(size)
      end
    end
    result 
  end

  def version_hash
    result = []
    @builds.simple_builds.each do |build|
      auto = @automations.find {|a| a.short_name == build.name }
      item = {
        "name" => auto ? auto.name : build.name,
        "href" => build.name,
        "versions" => build.versions.reverse.map {|v| v.to_tag},
        "description" => auto ? auto.description : ''
      }
      result << item
    end
    result
  end
end