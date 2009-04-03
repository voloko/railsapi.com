require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Hpricot < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/why/hpricot.git'
  end
  
protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '--charset' << 'utf-8'
    options << '--title' << 'Hpricot'
    options << '--main' << 'README'
    
    file_list = Rake::FileList.new
    file_list.include('README')
    file_list.include('CHANGELOG')
    file_list.include('COPYING')
    file_list.include('lib/**/*.rb')
    
    options += file_list
    RDoc::RDoc.new.document(options)
  end
end