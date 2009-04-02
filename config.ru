require 'rubygems'
require 'sinatra'

root_dir = File.dirname(__FILE__)
app_file = File.join(root_dir, 'sdoc-site.rb')

set :run => false
set :environment => :development
set :app_file => app_file

configure :production do
  require app_file
end

configure :development do
  set :reload => true
end


run Sinatra.application