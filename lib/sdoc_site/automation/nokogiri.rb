require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Nokogiri < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/tenderlove/nokogiri.git'
  end
  
protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '--charset' << 'utf-8'
    options << '--title' << 'Nokogiri'
    options << '-T' << 'direct'
    options << '--main' << 'README'
    
    file_list = Rake::FileList.new
    file_list.include('*.rdoc')
    file_list.include('lib')
    
    options += file_list
    RDoc::RDoc.new.document(options)
  end
end