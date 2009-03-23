module SDocSite
  class Version
    include Comparable
  
    attr_accessor :major, :minor, :tiny, :other
    def initialize(str)
      @str = str
      m = str.match /\D*(\d+)\.(\d+)(?:\.(\d+)(.*)?)?/
      @major = m[1]
      @minor = m[2]
      @tiny  = m[3] || ''
      @other = m[4] || ''
    end
  
    def <=>(version)
      if major == version.major
        if minor == version.minor
          if tiny == version.tiny
            if other == version.other
              return 0
            end
            return other <=> version.other
          end
          return tiny <=> version.tiny
        end
        return minor <=> version.minor
      end
      return major <=> version.major
    end
  
    def to_s
      "#{major}.#{minor}.#{tiny}#{other}"
    end
    
    def to_tag
      "v#{major}.#{minor}" + (tiny.empty? ? '' : ".#{tiny}") + other
    end
  end
end
