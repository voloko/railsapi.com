require "sdoc_site"

class SDocSite::Version
  include Comparable

  attr_accessor :major, :minor, :tiny, :other
  def initialize(tag)
    @tag = tag
    m = tag.match /\D*(\d+)\.(\d+)(?:\.(\d+)(.*)?)?/
    @major = m[1]
    @minor = m[2]
    @tiny  = m[3] || ''
    @other = m[4] || ''
  end

  def <=>(version)
    [major, minor, tiny, other] <=> [version.major, version.minor, version.tiny, version.other]
  end

  def to_s
    "#{major}.#{minor}" + (tiny ? ".#{tiny}#{other}" : '');
  end
  
  def to_tag
    # "v#{major}.#{minor}" + (tiny.empty? ? '' : ".#{tiny}") + other
    @tag
  end
end
