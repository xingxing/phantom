# -*- coding: utf-8 -*-
require 'sinatra'
configure { set :server, :puma }
require 'digest/md5' 

get "/" do
  "<h1>It works!</h1>"
end

# 1. 用phantomjs抓图片, 放到tmp下面随机生成uuid作为文件名
# 2. 对文件做MD5摘要
# 3. 取MD5前5个字母作为final_path e.g. public/images/3/1/7/c/8/8f6b2cec-b1a9-41fa-8c6f-8ef8a7216ac2.jpg
# 4. mv tmp_file to final_path
# 5. {success: 1, url: <IMAGE_URL>}
#    {success: 0, reason: <String> }
#    File stream
get "/phantoms" do
  format = 'jpg'

  file_name     = "#{SecureRandom.uuid}.#{format}"
  tmp_file_name = File.join('tmp', file_name)
  `phantomjs lib/rasterize.js http://www.tianji.com #{tmp_file_name}`

  md5 = Digest::MD5.hexdigest(File.read(tmp_file_name))
  final_dir = File.join('public', md5[0..4].split('') * '/')
  FileUtils.mkdir_p(final_dir)
  
  FileUtils.mv tmp_file_name, File.join(final_dir, "#{md5}.#{format}")

  
  
end
