require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Sinatra < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/sinatra/sinatra.git'
  end
  
protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '--charset' << 'utf-8'
    options << '--title' << 'Hpricot'
    options << '--main' << 'README.rdoc'
    
    file_list = Rake::FileList['README.rdoc', 'lib/**/*.rb']
    
    options += file_list
    RDoc::RDoc.new.document(options)
  end
end