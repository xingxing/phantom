# -*- coding: utf-8 -*-
=begin
  用 Phantomjs 抓取网页 转化为图片
=end

require 'digest/md5'
require "securerandom"
require "uri"
require "pathname"

class Phantom

  # 可执行文件位置
  PhantomjsExec = "phantomjs"

  PhantomExtname = %w{ png jpeg jpg jpe jfif jfi jif gif pdf }

  # phantomjs 脚本位置
  PhantomjsPath = File.join(File.expand_path('../../lib', __FILE__), 'rasterize.js')

  # 临时文件 存放目录
  Tmp = File.expand_path('../../tmp', __FILE__)

  # public directory path
  Pub = File.expand_path('../../public', __FILE__)

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
    # 2. 对文件做MD5摘要
    # 3. 取MD5前5个字母作为final_path e.g. public/images/3/1/7/c/8/8f6b2cec-b1a9-41fa-8c6f-8ef8a7216ac2.jpg
    # 4. mv tmp_file to final_path
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
    def destroy md5
      phantom = mock_phantom md5

      if File.exist? phantom.final_file_path
        FileUtils.rm(phantom.final_file_path)
        rm_recurse Pathname.new(phantom.final_file_path).split.first
        return {success: 1}
      end
    end

    # 递归删除空文件夹
    def rm_recurse path

      return false unless path.to_s =~ Regexp.new(Fin)

      if path.to_s.eql?(Pub)
        true
      else
        Dir["#{path}/*"]
          .select { |d| File.directory? d }                    
          .select { |d| dir_empty?(d) }
          .each { |d| Dir.rmdir(d) }
        
        rm_recurse path.split.first
      end
    end

    # 查找图片
    def find md5
      phantom = mock_phantom md5
      Phantom::PhantomExtname.map{|n| ".#{n}"}.map{|n| phantom.final_url.sub(/\..*$/, n)}.find_all{|n| File.exist? n }.first
    end

    private

    def dir_empty? path
      (Dir.entries(path) - %w{. ..}).size.zero?
    end

    # 为调用实例方法 mock 实例
    def mock_phantom md5
      phantom = self.new("http://www.baidu.com")
      phantom.md5 = md5
      phantom
    end
  end

  def genrate_image
    # 偶然发现 sohu.com 总是执行异常
    raise(PhantomException::PhantomjsExecError, "Phantomjs execution error!") unless `#{PhantomjsExec} #{PhantomjsPath} #{url} #{self.tmp_file_path}` == "Success!\n"
  end

  def tmp_file_path
    File.join Tmp, tmp_file_name
  end

  def final_file_directory
    self.md5[0..4].split(//) * '/'
  end

  def final_file_name
    "#{self.md5}.#{self.format}"
  end

  def final_file_path
    return "" unless self.md5
    File.join(Fin, final_file_directory, final_file_name)
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
    raise(PhantomException::IllegalFormat, "Beside PNG format, PhantomJS supports JPEG, GIF, and PDF.") unless PhantomExtname.include? @format.downcase
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
