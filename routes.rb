# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/json'

$:.unshift(File.expand_path('../models/', __FILE__))

require 'phantom'

get "/phantoms" do
  Phantom.all
end

#  {success: 1, url: <IMAGE_URL>}
#  {success: 0, reason: <String> }
#  File stream
post "/phantoms" do
  phantom_json = Phantom.create(url: params[:url], formate: params[:formate])

  if params[:file_stream]
    # content_type params[:formate]
    content = File.read phantom_json[:path]
    Phantom.destroy(phantom_json[:md5])
    content
  else
    phantom_json[:url] = url(phantom_json[:url]) if phantom_json[:url]
    json phantom_json
  end
end


get "/phantoms/:md5" do
  if phantom_json=Phantom.find(params[:md5])
    phantom_json[:url] = url(phantom_json[:url]) 
    json phantom_json
  else
    halt 404, "Sorry, such file doesn't exist!"
  end
end

delete "/phantoms/:md5" do
  if Phantom.destroy(params[:md5])
    json({success: 1})
  else
    halt 404, "Sorry, such file doesn't exist!"
  end
end
