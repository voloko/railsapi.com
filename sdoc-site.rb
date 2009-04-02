get '/doc/:build/*' do |build|
  pass unless params[:build].match(/\d+/)
  haml :building, :locals => {:build => params[:build]}
end