require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Eventmachine < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/eventmachine/eventmachine.git', :name => 'EventMachine', :short_name => 'eventmachine'
  end
  
  def build_doc version
    doc_dir = @automation.temp_dir
    `git clone #{@url} #{@tmp_path}`
    in_tmp do
      # versions prior to 0.12.6 are not compatible with sdoc
      `git checkout #{version.to_tag}` if version > SDocSite::Version.new('0.12.6')
      run_sdoc doc_dir
    end
    doc_dir
  end
  
  
protected
  def run_sdoc target
    `ruby -pi -e "gsub(/^#---/, '# ---')" lib/**/*.rb` # hack to get rid of inconsistent identation
    
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '--charset' << 'utf-8'
    options << '--title' << name
    options << '-T' << 'direct'
    options << '--main' << 'README.rdoc' if File.exists? 'README.rdoc'
    options << '--main' << 'README'      if File.exists? 'README'
    options << '--main' << 'docs/README' if File.exists? 'docs/README'
    
    file_list = Rake::FileList['README', 'README.rdoc', 'docs/*', 'lib/**/*.rb']
    file_list.exclude(*%w(lib/em/version lib/emva lib/evma/ lib/pr_eventmachine lib/jeventmachine))
    
    options += file_list
    RDoc::RDoc.new.document(options)
  end
end