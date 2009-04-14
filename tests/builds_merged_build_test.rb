require "test_helper"
require "sdoc_site/builds"

class BuildsMergedBuildTest < Test::Unit::TestCase
  include SDocSite::Builds
  
  def test_should_equal_merged_builds_in_any_order
    first = MergedBuild.from_str('a-v1.1_b-v2.1')
    second = MergedBuild.from_str('b-v2.1_a-v1.1')
    
    assert_equal(first, second)
  end
  
  def test_should_not_equal_different_merged_builds
    first = MergedBuild.from_str('a-v1.1_b-v2.1')
    second = MergedBuild.from_str('b-v2.1_c-v1.1')
    
    assert_not_equal(first, second)
  end  
  
  def test_should_find_same_major
    a = MergedBuild.from_str('a-v1.1.1_b-v2.1.1')
    b = MergedBuild.from_str('b-v2.1.2_a-v1.1')
    c = MergedBuild.from_str('a-v1.1.2_b-v2.2.1')
    d = MergedBuild.from_str('a-v1.1.2_b-v2.1_c-v1.1')
    
    assert(a.same_minor?(b), 'A should have same major as b')
    assert(b.same_minor?(a), 'B should have same major as a')
    assert(!c.same_minor?(a), 'C should not have same major as a')
    assert(!d.same_minor?(a), 'D should not have same major as a')
  end
  
  def test_shuold_find_same_names
    a = MergedBuild.from_str('a-v1.1.1_b-v2.1.1')
    assert(a.same_names?(%w(b a)), 'Have a and b names')
    assert(!a.same_names?(%w(d a)), 'Does not have d')
    assert(!a.same_names?(%w(c b a)), 'Does not have c')
  end
end