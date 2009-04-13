class SDocSite::Builds::List
  include SDocSite::Builds
  
  attr_accessor :root
  
  def initialize(root)
    @root = root
  end
  
  def simple_builds
    raw_builds = select_dirs SIMPLE_BUILD_REGEXP
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
  
  def simple_build build
    simple_builds.find { |b| b == build }
  end
  
  def simple_build_by_name name
    simple_builds.find { |b| b.name == name }
  end
  
  def merged_builds
    raw_builds = select_dirs MERGED_BUILD_REGEXP
    result = []
    raw_builds.each do |raw|
      result << MergedBuild.from_str(raw)
    end
    result
  end
  
  def merged_build build
    merged_builds.find { |b| b == build }
  end
  
protected
  def select_dirs regexp
    Dir.new(@root).select do |name|
      File.directory?(File.join(@root, name)) && name.match(regexp)
    end
  end  
end