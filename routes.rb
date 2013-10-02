# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/json'
configure { set :server, :puma }

$:.unshift(File.expand_path('../models/', __FILE__))

require 'phantom'

get "/" do
  "<h1>It works!</h1>"
end

#  {success: 1, url: <IMAGE_URL>}
#  {success: 0, reason: <String> }
#  File stream
get "/phantoms" do
  json Phantom.create(url: "http://www.tianji.com", formate: 'jpg')
end
