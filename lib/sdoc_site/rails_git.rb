require "sdoc_site/version"
require "yaml"

module SDocSite
  class RailsGit
    attr_reader :rails_dir
    
    def initialize(rails_dir)
      @rails_dir = File.expand_path(rails_dir)
      update
    end
    
    def update
      if File.exists? rails_dir
        in_rails_dir do 
          # `git pull origin`
        end
      else
        `git clone git://github.com/rails/rails.git #{rails_dir}`
      end
    end

    def all_versions
      tags = nil
      in_rails_dir do 
        tags = `git tag`
        tags.split /\n/
      end
      tags.map { |tag| SDocSite::Version.new(tag) }
    end
    
    def co_version(version)
      in_rails_dir do
        `git checkout #{version.to_tag}`
      end
    end
    
    def extract_rdoc_includes &block
      extract_lines /\.include\(['"]([^'"]+)['"]\)/, &block
    end
    
    def extract_rdoc_excludes &block
      extract_lines /\.exclude\(['"]([^'"]+)['"]\)/, &block
    end
    
    def in_rails_dir &block
      cwd = Dir.pwd
      Dir.chdir rails_dir
      yield
      Dir.chdir cwd
    end
    
    def generated_versions
      versions = []
      if File.exists? 'versions.yaml'
        data = YAML::load open('versions.yaml').read
        versions = data[:versions]
      end
      versions
    end
    
    def add_generated_version(version)
      versions = generated_versions
      unless versions.include? version.to_tag
        versions << version.to_tag
      end
      File.open('versions.yaml', 'w') do |f|
        data = {
          :versions => versions
        }
        f.write(data.to_yaml) 
      end
    end
    
  protected
    def extract_lines(regexp, &block)
      lines = []
      in_rails_dir do
        File.open('Rakefile') do |f|
          f.each_line do |l|
            if m = l.match(regexp)
              lines.push m[1]
            end
          end
        end
      end
      lines
    end
  end
end
