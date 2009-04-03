require "sdoc_site/version"
require "sdoc"

class SDocSite::Automation::Ruby
  def initialize automation
    @automation = automation
    @tmp_path = @automation.temp_dir
  end
  
  def name
    'Ruby'
  end
  
  def description
    ''
  end
  
  def short_name
    'ruby'
  end
  
  def versions_to_build
    2
  end
  
  def available_versions
    [SDocSite::Version.new('1.8'), SDocSite::Version.new('1.9')]
  end
  
  def build_doc version
    doc_dir = @automation.temp_dir
    if version.minor == '8'
      `svn checkout http://svn.ruby-lang.org/repos/ruby/tags/v1_8_7_99 #{@tmp_path}`
      in_tmp do
        run_sdoc_1_8 doc_dir
      end
    else
      `svn checkout http://svn.ruby-lang.org/repos/ruby/tags/v1_9_1_0 #{@tmp_path}`
      in_tmp do
        run_sdoc_1_9 doc_dir
      end
    end
    doc_dir
  end
  
protected
  def run_sdoc_1_8 target
    options = []
    options << "-o" << target
    options << '--line-numbers' 
    options << '-x' << 'lib/rdoc'
    options << '-x' << 'ext/win32ole'
    options << '-x' << 'lib/rss'
    options << '-x' << 'lib/runit'
    options << '-x' << 'lib/irb'
    options << '-x' << 'lib/rinda'
    options << '-x' << 'lib/webrick'
    options << './README'
    options << './COPYING'
    options << './NEWS'
    options << './ChangeLog'
    options << './LEGAL'
    options << './LGPL'
    options << './GPL'
    options << '.'
    RDoc::RDoc.new.document(options)
  end
  
  def run_sdoc_1_9 target
    options = []
    options << "-o" << target
    options << '-x' << 'ext/win32ole'
    options << '--line-numbers' 
    options << './README'
    options << './COPYING'
    options << './NEWS'
    options << './ChangeLog'
    options << './LEGAL'
    options << './LGPL'
    options << './GPL'
    options += %w(*.c *.rb ext lib/*.rb lib/*.c lib/cgi lib/date lib/net lib/racc lib/rbconfig lib/rexml lib/rubygems lib/shell lib/test lib/uri lib/xmlrpc/ lib/yaml)
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