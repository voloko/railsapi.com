require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Authlogic < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/binarylogic/authlogic.git'
  end
  
  def available_versions
    [SDocSite::Version.new('2.0.6')]
  end
  
  def build_doc version
    doc_dir = @automation.temp_dir
    `git clone #{@url} #{@tmp_path}`
    in_tmp do
      run_sdoc doc_dir
    end
    doc_dir
  end
  
protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '--charset' << 'utf-8'
    options << '--title' << 'Authlogic'
    options << '-T' << 'direct'
    options << '--main' << 'README.rdoc'
    
    file_list = Rake::FileList.new
    file_list.include('README.rdoc')
    file_list.include('CHANGELOG.rdoc')
    file_list.include('lib/**/*.rb')
    options += file_list
    RDoc::RDoc.new.document(options)
  end
end