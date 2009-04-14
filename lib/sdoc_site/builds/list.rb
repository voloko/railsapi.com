class SDocSite::Builds::List
  include SDocSite::Builds
  
  attr_accessor :root
  
  def initialize(root)
    @root = root
    reset
  end
  
  def reset
    @simple_builds = nil
    @merged_builds = nil
  end
  
  def simple_builds
    @simple_builds ||= fetch_simple_builds
  end
  
  def simple_build build
    simple_builds.find { |b| b == build }
  end
  
  def simple_build_by_name name
    simple_builds.find { |b| b.name == name }
  end
  
  def merged_builds
    @merged_builds ||= fetch_merged_builds
  end
  
  def merged_build build
    merged_builds.find { |b| b == build }
  end
  
  def merged_builds_by_names names
    merged_builds.select { |b| b.same_names?(names) }
  end
  
protected
  def select_dirs regexp
    Dir.new(@root).select do |name|
      File.directory?(File.join(@root, name)) && name.match(regexp)
    end
  end  
  
  def simple_builds_dirs
    select_dirs SIMPLE_BUILD_REGEXP
  end
  
  def merged_builds_dirs
    select_dirs MERGED_BUILD_REGEXP
  end
  
  def fetch_simple_builds
    raw_builds = simple_builds_dirs
    builds = {}
    raw_builds.each do |raw|
      build = Build.from_str raw
      unless builds.has_key? build.name
        builds[build.name] = build
      else
        builds[build.name].versions << build.versions.first
      end
    end
    builds.values
  end
  
  def fetch_merged_builds
    raw_builds = merged_builds_dirs
    result = []
    raw_builds.each do |raw|
      result << MergedBuild.from_str(raw)
    end
    result
  end
end