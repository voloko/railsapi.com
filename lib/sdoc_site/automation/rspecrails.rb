require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::RSpecRails < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/dchelimsky/rspec-rails.git'
  end
  
  def name
    'RSpec::Rails'
  end
end