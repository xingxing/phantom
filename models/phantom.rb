# -*- coding: utf-8 -*-
=begin
  用 Phantomjs 抓取网页 转化为图片
=end

require 'digest/md5'
require "securerandom"

class Phantom

  # 可执行文件位置
  PhantomjsExec = "phantomjs"

  # phantomjs 脚本位置
  PhantomjsPath = File.join(File.expand_path('../../lib', __FILE__), 'rasterize.js')

  # 临时文件 存放目录
  Tmp = File.expand_path('../../tmp', __FILE__)

  # 最终文件 存放目录
  Fin = File.expand_path('../../public/images', __FILE__)

  attr_accessor :format, :md5, :url, :uuid

  attr_reader :tmp_file_name

  def initialize(url, format='jpg')
    @url   = url
    @format = format
    @tmp_file_name = genrate_tmp_file_name  
    valid_url
    valid_format
  end

  class << self
    # 抓取图片
    # 1. 用phantomjs抓图片, 放到tmp下面随机生成uuid作为文件名
    def create opts={}
      phantom = Phantom.new(opts[:url], opts[:formate])
      phantom.genrate_image
      phantom.md5 = Digest::MD5.hexdigest(File.read(phantom.tmp_file_path))
      FileUtils.mkdir_p(File.join(Fin, phantom.final_file_directory))
      FileUtils.mv(phantom.tmp_file_path, phantom.final_file_path)
      {success: 1, url: phantom.final_url}
    rescue Exception => e
      {success: 0, reason: e.message}
    end

    # 删除图片
    def destroy
      
    end

    # 查找图片
    def find md5
      
    end
  end

  def genrate_image
    raise(PhantomException::PhantomjsExecError, "Phantomjs execution error!") unless `#{PhantomjsExec} #{PhantomjsPath} #{url} #{self.tmp_file_path}` == "Success!\n"
  end

  def tmp_file_path
    File.join Tmp, tmp_file_name
  end

  def final_file_directory
    self.md5[0..4].split(//) * '/'
  end

  def final_file_path
    return "" unless self.md5
    File.join(Fin, final_file_directory, "#{self.md5}.#{self.format}")
  end

  def final_url
    self.final_file_path.split("public")[1]
  end

  private

  def genrate_tmp_file_name
    "#{SecureRandom.uuid}.#{self.format}"
  end

  def valid_url
    raise(PhantomException::IllegalUrl, "IllegalUrl") unless @url =~ URI::regexp
  end
  
  def valid_format
    raise(PhantomException::IllegalFormat, "Beside PNG format, PhantomJS supports JPEG, GIF, and PDF.") unless %w{ png jpeg jpg jpe jfif jfi jif gif pdf }.include? @format.downcase
  end

end

module PhantomException
  class IllegalFormat < Exception
  end

  class IllegalUrl < Exception
  end

  class PhantomException::PhantomjsExecError < Exception
  end
end
