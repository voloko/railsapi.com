require "sdoc_site"

module SDocSite::Builds
  SIMPLE_BUILD_REGEXP = /^([^_-]+)-([^_-]+)$/
  MERGED_BUILD_REGEXP = /^([^_-]+-[^_-]+_)+[^_-]+-[^_-]+$/
end

require "sdoc_site/builds/build"
require "sdoc_site/builds/merged_build"
require "sdoc_site/builds/list"