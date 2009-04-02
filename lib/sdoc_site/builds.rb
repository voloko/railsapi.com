require "sdoc_site"
require "sdoc_site/version"

class SDocSite::Builds
  attr_accessor :root
  
  SIMPLE_BUILD_REGEXP = /^([^_-]+)-([^_-]+)$/
  MERGED_BUILD_REGEXP = /^([^_-]+-[^_-]+_)+[^_-]+-[^_-]+$/
  
  class Build
    attr_accessor :name
    attr_accessor :versions
    
    def initialize(name, versions = [])
      @name = name
      @versions = versions
    end
  end
  
  class MergedBuild
    attr_accessor :builds
    
    def initialize
      @builds = []
    end
  end
  
  def initialize(root)
    @root = root
  end
  
  def simple_builds
    raw_builds = select_dirs SIMPLE_BUILD_REGEXP
    builds = {}
    raw_builds.each do |raw|
      (tmp, name, version) = *raw.match(SIMPLE_BUILD_REGEXP)
      builds[name] ||= Build.new name
      builds[name].versions << SDocSite::Version.new(version)
    end
    builds.values
  end
  
  def merged_builds
    raw_builds = select_dirs MERGED_BUILD_REGEXP
    result = []
    raw_builds.each do |raw|
      parts = raw.split('_')
      merged = MergedBuild.new
      parts.each do |part|
        (tmp, name, version) = *part.match(SIMPLE_BUILD_REGEXP)
        merged.builds << Build.new(name, [SDocSite::Version.new(version)])
      end
      result << merged
    end
    result
  end
  
protected
  def select_dirs regexp
    Dir.new(@root).select do |name|
      File.directory?(File.join(@root, name)) && name.match(regexp)
    end
  end
end