require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Awss3 < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/marcel/aws-s3.git'
  end
  
  def name
    'AWS-S3'
  end
end