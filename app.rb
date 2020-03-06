require 'sinatra'
require 'json'
require_relative 'lib/url_util.rb'

url_util = URLUtil.new

# params - short_url
# Redirects to homepage is no short link
# Redirects to actual link
get '/:short_url' do 
  original_url = url_util.get_full_url(params[:short_url])
  redirect to(original_url), 302
end

# Json payload - eg: {"url":"www.example.com"} - for auto generating short links
# Json payload - eg: {"url":"www.example.com", "custom":"custom_link"} - for creating custom short links
# Responds with the short link
post '/shorten_url' do
  params = JSON.parse(request.body.read, {symbolize_keys: true})
  [200, {"Content-Type" => "application/json"}, url_util.shorten(params["url"], params["custom"])]
end

# params - short_url
# if short_url is nil, should respond with stats for all short links - NOT COMPLETE
# if short_url is not nil, should respond with stats for given short link
# responds with stats in json format
get '/stats/:short_url' do
  [200, {"Content-Type" => "application/json"}, url_util.get_stats(params["short_url"]).to_json]
end
