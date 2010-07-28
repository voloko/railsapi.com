require 'sinatra'
require "sdoc_site"
require "sdoc_site/builds"

get '/doc/:something' do
  redirect "/doc/#{params[:something]}/"
end

get %r{/doc/([^/]+)/([^/]*)} do
  path = params["captures"][0]
  remainder = params["captures"][1]
  list = SDocSite::Builds::List.new(File.join('public', 'doc'))
  locks = SDocSite::Locks.new('lock')
  
  begin
    if path.match(SDocSite::Builds::MERGED_BUILD_REGEXP)
      list.merged_builds.each do |merged|
        pass if merged.to_s == path # build exists but we still get to sinatra => /doc/build-v1_buildx-v2/something_unexistent
      end
      if locks.locked? path
        return haml(:building, :locals => {:build => path})
      end
    end

    try_redirecting_to_closest_minor list, path, remainder
    try_redirecting_to_max_version list, path, remainder
    try_redirecting_to_closest_minor_or_merging locks, list, path, remainder
    try_redirecting_to_max_merged_version list, path, remainder
  end
  
  
  pass
end

get '/*' do
  pass if params['splat'][0][0..3] == 'doc/'
  redirect "/doc/#{params['splat'][0]}"
end

def try_redirecting_to_closest_minor list, path, remainder
  if path.match(SDocSite::Builds::SIMPLE_BUILD_REGEXP)
    searched_build = SDocSite::Builds::Build.from_str(path)

    build = list.simple_build_by_name searched_build.name
    build.each_versioned_build do |existing|
      pass if existing == searched_build # build exists but we still get to sinatra => /doc/build-v1/something_unexistent
      redirect "/doc/#{existing.to_s}/#{remainder}" if existing.same_minor?(searched_build)
    end if build
    pass
  end
end

def try_redirecting_to_max_version list, path, remainder
  if path.match(/^[^_-]+$/)
    searched_name = path
    existing = list.simple_build_by_name searched_name
    redirect "/doc/#{searched_name}-#{existing.versions.max.to_tag}/#{remainder}" if existing 
    pass
  end
end

def try_redirecting_to_closest_minor_or_merging locks, list, path, remainder
  if path.match(SDocSite::Builds::MERGED_BUILD_REGEXP)
    
    searched_build = SDocSite::Builds::MergedBuild.from_str(path)

    goto_build = SDocSite::Builds::MergedBuild.new
    searched_build.builds.each do |part|
      existing = list.simple_build_by_name part.name
      pass unless existing
      same_minor = existing.versioned_builds.find {|e| e.same_minor? part }
      pass unless same_minor
      goto_build.builds << same_minor
    end
    
    if goto_build.to_s == path #should merge
      begin
        locks.lock path
        require "sdoc_site/automation"
        a = SDocSite::Automation.new File.expand_path(list.root)
        a.merge_builds goto_build
        a.generate_index
      ensure
        locks.unlock path
      end
    end
    
    # reload or redirect
    redirect "/doc/#{goto_build}/#{remainder}"
  end
end

def try_redirecting_to_max_merged_version list, path, remainder
  if path.match(/^[^_-]+(_[^_-]+)*$/)
    searched_names = path.split('_')
    goto_build = SDocSite::Builds::MergedBuild.new
    searched_names.each do |part|
      existing = list.simple_build_by_name part
      pass unless existing
      goto_build.builds << existing.versioned_builds.max
    end
    redirect "/doc/#{goto_build}/#{remainder}"
    pass
  end
end

class SDocSite::Locks
  def initialize(root)
    @root = root
  end
  
  def locked? name
    File.exists? File.join(@root, name)
  end
  
  def unlock name
    require 'fileutils'
    FileUtils.rm_rf File.join(@root, name)
  end
  
  def lock name
    Dir.mkdir File.join(@root, name)
  end
end