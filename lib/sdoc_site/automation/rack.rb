require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Rack < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/rack/rack.git'
  end
  
protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '--charset' << 'utf-8'
    options << '--title' << 'RSpec'
    options << '--main' << 'README'
    
    file_list = Rake::FileList.new
    file_list.include('*.rdoc')
    file_list.include('lib/**/*.rb')
    
    options += file_list
    RDoc::RDoc.new.document(options)
  end
end