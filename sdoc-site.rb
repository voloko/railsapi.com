$:.unshift ::File.expand_path(::File.join(::File.dirname(__FILE__), 'lib/'))
require "sdoc_site"
require "sdoc_site/builds"

get '/doc/:build/*' do |build|
  begin
    builds = SDocSite::Builds.new(File.join('public', 'doc'))
    merged_build = SDocSite::Builds::MergedBuild.from_str params[:build]
    available_build = builds.merged_build(merged_build)
    if available_build
      redirect "/doc/#{available_build}"
    end
    require "sdoc_site/automation"
    a = SDocSite::Automation.new File.expand_path(File.join('public', 'doc'))
    a.merge_builds merged_build
    a.generate_index
  rescue Exception => e
    return e.to_s + e.backtrace.to_s
  end
  haml :building, :locals => {:build => params[:build]}
end