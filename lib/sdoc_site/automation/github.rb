require "sdoc_site/version"
require "sdoc"

class SDocSite::Automation::Github
  def initialize automation, url
    @automation = automation
    @url = url
    @tmp_path = @automation.temp_dir
  end
  
  def short_name
    File.basename @url, '.git'
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
      run_sdoc doc_dir
    end
    doc_dir
  end
  
protected
  def run_sdoc target
    in_tmp do
      options = []
      options << "-o" << target
      options << '--line-numbers' 
      options << './README' if File.exists? 'README'
      options << 'lib/'
      RDoc::RDoc.new.document(options)
    end
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