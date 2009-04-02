require "test_helper"
require "sdoc_site/version"

class VersionTest < Test::Unit::TestCase
  def test_should_compare
    a = SDocSite::Version.new('v1.3.2')
    b = SDocSite::Version.new('v1.3.3')
    assert(a < b, "A should be less than b")
  end
end