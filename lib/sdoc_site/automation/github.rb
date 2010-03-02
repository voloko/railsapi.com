require "sdoc_site/version"
require "sdoc"

class SDocSite::Automation::Github
  def initialize automation, url, options = {}
    @automation = automation
    @url = url
    @tmp_path = @automation.temp_dir
    @options = options
  end
  
  def name
    @options[:name] || short_name[0,1].upcase + short_name[1..-1]
  end
  
  def description
    @options[:description] || ''
  end
  
  def short_name
    @options[:short_name] || File.basename(@url, '.git').gsub(/[^\w\d]/, '')
  end
  
  def available_versions
    tags = nil
    tags = `git ls-remote --tags #{@url}`
    tags.split(/\n/).map do |tag| 
      version = tag.sub(%r{^.*refs/tags/}, '').sub(%r{\^.*$}, '')
      SDocSite::Version.new(version)
    end
  end
  
  def build_doc version
    doc_dir = @automation.temp_dir
    `git clone #{@url} #{@tmp_path}`
    in_tmp do
      `git checkout #{version.to_tag}`

      @version = version
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
    options << '--title' << name
    options << '-T' << 'direct'
    options << '--main' << 'README.rdoc' if File.exist? 'README.rdoc'
    options << '--main' << 'README' if File.exist? 'README'
    
    file_list = Rake::FileList.new
    # add if any
    file_list.include('README')
    file_list.include('COPYING')
    file_list.include('INSTALL')
    
    file_list.include('*.rdoc')
    file_list.include('lib/**/*.rb')
    
    options += file_list
    RDoc::RDoc.new.document(options)
  end

  def in_tmp &block
    cwd = Dir.pwd
    begin
      Dir.chdir @tmp_path
      yield
    ensure
      Dir.chdir cwd
    end
  end
end