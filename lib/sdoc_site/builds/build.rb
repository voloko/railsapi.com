class SDocSite::Builds::Build
  include Comparable
  include SDocSite::Builds
  
  attr_accessor :name
  attr_accessor :versions
  attr_accessor :original
  
  def initialize(name, versions = [])
    @name = name
    @versions = versions
  end
  
  def version
    @versions.max
  end
  
  def self.from_str str
    (tmp, name, version) = *str.match(SIMPLE_BUILD_REGEXP)
    build = self.new name, [SDocSite::Version.new(version)]
    build.original = str
    build
  end
  
  def to_s
    @original || "#{name}-#{versions.max.to_tag}"
  end
  
  def <=>(other)
    [@name, @versions.max] <=> [other.name, other.versions.max]
  end
  
  def ==(other)
    other.name == @name && @versions.sort == other.versions.sort
  end
  
  def same_minor? build
    @name == build.name && version.same_minor?(build.version)
  end
end