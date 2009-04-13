class SDocSite::Builds::MergedBuild
  attr_accessor :builds, :original
  include SDocSite::Builds
  
  def initialize
    @builds = []
    @original = nil
  end
  
  def ==(other)
    builds.sort == other.builds.sort
  end
  
  def self.from_str str
    parts = str.split('_')
    merged = self.new
    parts.each do |part|
      merged.builds << Build.from_str(part)
    end
    merged.original = str
    merged
  end
  
  def to_s
    @original || @builds.join('_')
  end
  
  def same_minor? merged
    return false if builds.size != merged.builds.size
    sorted = merged.builds.sort
    @builds.sort.each_with_index do |build, index|
      return false unless build.same_minor?(sorted[index])
    end
    return true
  end

end