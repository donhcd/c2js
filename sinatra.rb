require 'sinatra'
require 'cgi'
require 'open-uri'

default_code =
  "int fib(int i) {
  int f1=0;
  int f2=1;
  for (int q=0; q<i-1; q++) {
    f1 += f2;
    f2 ^= f1;
    f1 ^= f2;
    f2 ^= f1;
  }
  return f1;
}

int main(){
  printf(\"%d\",fib(7));
  return 0;
}"

get '/' do
  erb :index, :locals => {
    :ccode => default_code
  }
end

get '/try' do
  erb :index, :locals => {
    :ccode => CGI.unescape(params[:code])
  }
end

get '/dbdl' do
  url = CGI.unescape(params[:url])
  result = open(url, 'rb').read()
  puts(url)
  puts(result);
  result
end
