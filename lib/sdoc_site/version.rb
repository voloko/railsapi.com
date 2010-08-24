require "sdoc_site"

class SDocSite::Version
  include Comparable

  attr_accessor :major, :minor, :tiny, :other, :beta
  
  def initialize(tagname = '')
    @tag   = tagname
    @major = @minor = '0'
    @tiny  = @other = ''
    m = tagname.match(/\D*(\d+)\.(\d+)(?:\.(\d+)(.*)?)?/)
    if m
      @major = m[1]
      @minor = m[2]
      @tiny  = m[3] || ''
      @other = m[4] || ''
      @tiny  = @tiny.gsub(/[^\d\w.]/, '').gsub(/[_-]/, '')
      @other = @other.gsub(/[^\d\w]/, '').gsub(/[_-]/, '')
      @beta  = !!@other.match(/beta|alpha/) 
    end
  end

  def <=>(version)
    [beta ? 0 : 1, major, minor, tiny, other] <=> [version.beta ? 0 : 1, version.major, version.minor, version.tiny, version.other]
  end

  def to_s
    "#{major}.#{minor}" + (tiny.empty? ? '' : ".#{tiny}#{other}");
  end
  
  def to_tag
    # "v#{major}.#{minor}" + (tiny.empty? ? '' : ".#{tiny}") + other
    @tag
  end
  
  def same_minor? version
    return @major == version.major && @minor == version.minor 
  end
end
