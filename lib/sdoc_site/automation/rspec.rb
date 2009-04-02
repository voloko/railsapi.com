require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::RSpec < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/dchelimsky/rspec.git'
  end
  
protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '--charset' << 'utf-8'
    options << '--title' << 'RSpec'
    
    file_list = Rake::FileList.new
    file_list.include('README')
    file_list.include('KNOWN-ISSUES')
    file_list.include('SPEC')
    file_list.include('RDOX')
    file_list.include('lib/**/*.rb')
    
    options += file_list
    RDoc::RDoc.new.document(options)
  end
end