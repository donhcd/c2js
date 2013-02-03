require 'sinatra'
require 'cgi'
require 'open-uri'


get '/' do
  erb :index
end

get '/dbdl' do
  url = CGI.unescape(params[:url])
  result = open(url, 'rb').read()
  puts(url)
  puts(result);
  result
end
