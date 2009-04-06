require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Haml < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/nex3/haml.git'
  end
  
protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '--charset' << 'utf-8'
    options << '--title' << 'Haml/Sass'
    options << '-T' << 'direct'
    options << '--main' << 'README.rdoc'
    
    file_list = Rake::FileList.new
    file_list.include('README.rdoc')
    file_list.include(*FileList.new('*') do |list|
                              list.exclude(/(^|[^.a-z])[a-z]+/)
                              list.exclude('TODO')
                      end.to_a)
    file_list.include('lib/**/*.rb')
    file_list.exclude('TODO')
    file_list.exclude('lib/haml/buffer.rb')
    file_list.exclude('lib/sass/tree/*')
    options += file_list
    RDoc::RDoc.new.document(options)
  end
end