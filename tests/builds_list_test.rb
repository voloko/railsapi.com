require "test_helper"
require "sdoc_site/builds"

class BuildsTest < Test::Unit::TestCase
  include SDocSite
  
  def test_should_return_all_simple_builds
    builds = Builds::List.new(fixtures_path 'builds')
    assert_equal(2, builds.simple_builds.size, 'Should find rails and ruby ')
  end
  
  def test_should_return_build_instances
    builds = Builds::List.new(fixtures_path 'builds')
    builds.simple_builds.each do |build|
      assert(build.respond_to? :name,     "Should be named")
      assert(build.respond_to? :versions, "Should have versions array")
    end
  end
  
  def test_should_return_all_merged_builds
    builds = Builds::List.new(fixtures_path 'builds')
    assert_equal(1, builds.merged_builds.size)
  end
  
  def test_should_return_merged_builds
    builds = Builds::List.new(fixtures_path 'builds')
    builds.merged_builds.each do |build|
      assert(build.respond_to? :builds,     "Should have builds")
    end
  end
  
end