require "test_helper"
require "sdoc_site/version"

class VersionTest < Test::Unit::TestCase
  include SDocSite
  
  def test_should_compare
    a = Version.new('v1.3.2')
    b = Version.new('v1.3.3')
    assert(a < b, "A should be less than b")
  end
  
  def test_should_find_same_minor
    a = Version.new('v1.2.2')
    b = Version.new('v1.2.3')
    c = Version.new('v2.2.3')
    
    assert(a.same_minor?(b), 'A should have same major as b')
    assert(b.same_minor?(a), 'B should have same major as a')
    assert(!c.same_minor?(a), 'C should not have same major as a')
  end
  
  def test_should_remove_special_chars
    a = Version.new('v1.2.2_RC2')
    assert(a.to_s, 'v1.2.2RC2')
  end
end