$:.unshift ::File.expand_path(::File.join(::File.dirname(__FILE__), 'lib/'))
require 'rubygems'
require 'sinatra'

set :run => false
set :environment => ENV['environment'] || :development
set :app_file => 'sdoc-site.rb'

configure :production do
  require app_file
end

configure :development do
  set :reload => true
end

run Sinatra.application