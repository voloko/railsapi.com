require "test_helper"
require "sdoc_site/builds"


class BuildsBuildTest < Test::Unit::TestCase
  include SDocSite
  include SDocSite::Builds
  
  def test_should_equal_same_builds
    first = Build.from_str('a-v1.1')
    first.versions << Version.new('v1.2')
    second = Build.from_str('a-v1.1')
    second.versions << Version.new('v1.2')
    
    assert_equal(first, second)
  end
  
  def test_should_not_equal_different_builds
    first = Build.from_str('a-v1.1')
    first.versions << Version.new('v1.2')
    second = Build.from_str('a-v1.1')
    
    assert_not_equal(first, second)
  end
  
  def test_should_order_builds
    builds = []
    builds << Build.from_str('c-v1.0')
    builds << Build.from_str('a-v1.1')
    builds << Build.from_str('a-v1.2')
    
    builds.sort!
    assert_equal('a-v1.1', builds[0].to_s)
    assert_equal('a-v1.2', builds[1].to_s)
    assert_equal('c-v1.0', builds[2].to_s)
  end
  
  def test_should_find_same_major
    a = Build.from_str('a-v1.1.1')
    b = Build.from_str('a-v1.1.2RC')
    c = Build.from_str('b-v1.1.1')
    d = Build.from_str('a-v1.2.1')

    assert(a.same_minor?(b), 'A should have same major as b')
    assert(b.same_minor?(a), 'B should have same major as a')
    assert(!c.same_minor?(a), 'C should not have same major as a')
    assert(!d.same_minor?(a), 'D should not have same major as a')
  end
  
end