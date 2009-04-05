$:.unshift ::File.expand_path(::File.join(::File.dirname(__FILE__), 'lib/'))
require "sdoc_site"
require "sdoc_site/builds"

get '/doc/:build/*' do
  begin
    
    builds = SDocSite::Builds.new(File.join('public', 'doc'))
    merged_build = SDocSite::Builds::MergedBuild.from_str params[:build]
    available_build = builds.merged_build(merged_build)
    
    public_dir = File.join('public', 'doc')
    target = File.join public_dir, merged_build.to_s
    if File.exists?(target)
      return haml(:building, :locals => {:build => params[:build]})
    end
    
    if available_build
      redirect "/doc/#{available_build}/"
    end
    
    require "sdoc_site/automation"
    Dir.mkdir target
    a = SDocSite::Automation.new File.expand_path(public_dir)
    a.merge_builds merged_build
    a.generate_index
    redirect "/doc/#{merged_build}/"
    
  rescue Exception => e
    e.to_s
  end
end