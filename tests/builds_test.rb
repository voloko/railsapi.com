require "test_helper"
require "sdoc_site/builds"

class BuildsTest < Test::Unit::TestCase
  def test_should_return_all_simple_builds
    builds = SDocSite::Builds.new(fixtures_path 'builds')
    assert_equal(2, builds.simple_builds.size, 'Should find rails and ruby ')
  end
  
  def test_should_return_build_instances
    builds = SDocSite::Builds.new(fixtures_path 'builds')
    builds.simple_builds.each do |build|
      assert(build.respond_to? :name,     "Should be named")
      assert(build.respond_to? :versions, "Should have versions array")
    end
  end
  
  def test_should_return_all_merged_builds
    builds = SDocSite::Builds.new(fixtures_path 'builds')
    assert_equal(1, builds.merged_builds.size)
  end
  
  def test_should_return_merged_builds
    builds = SDocSite::Builds.new(fixtures_path 'builds')
    builds.merged_builds.each do |build|
      assert(build.respond_to? :builds,     "Should have builds")
    end
  end
  
  def test_should_equal_same_builds
    first = SDocSite::Builds::Build.from_str('a-v1.1')
    first.versions << SDocSite::Version.new('v1.2')
    second = SDocSite::Builds::Build.from_str('a-v1.1')
    second.versions << SDocSite::Version.new('v1.2')
    
    assert_equal(first, second)
  end
  
  def test_should_not_equal_different_builds
    first = SDocSite::Builds::Build.from_str('a-v1.1')
    first.versions << SDocSite::Version.new('v1.2')
    second = SDocSite::Builds::Build.from_str('a-v1.1')
    
    assert_not_equal(first, second)
  end
  
  def test_should_order_builds
    builds = []
    builds << SDocSite::Builds::Build.from_str('c-v1.0')
    builds << SDocSite::Builds::Build.from_str('a-v1.1')
    builds << SDocSite::Builds::Build.from_str('a-v1.2')
    
    builds.sort!
    assert_equal('a-v1.1', builds[0].to_s)
    assert_equal('a-v1.2', builds[1].to_s)
    assert_equal('c-v1.0', builds[2].to_s)
  end
  
  def test_should_equal_merged_builds_in_any_order
    first = SDocSite::Builds::MergedBuild.from_str('a-v1.1_b-v2.1')
    second = SDocSite::Builds::MergedBuild.from_str('b-v2.1_a-v1.1')
    
    assert_equal(first, second)
  end
  
  def test_should_not_equal_different_merged_builds
    first = SDocSite::Builds::MergedBuild.from_str('a-v1.1_b-v2.1')
    second = SDocSite::Builds::MergedBuild.from_str('b-v2.1_c-v1.1')
    
    assert_not_equal(first, second)
  end
end