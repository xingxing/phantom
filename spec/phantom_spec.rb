# -*- coding: utf-8 -*-
require "spec_helper"
require "phantom"

describe Phantom do

  let(:url){'http://www.tianji.com'}

  describe ".new" do
    context "when 格式不合法" do
      it "should 抛出异常" do
        expect { Phantom.new(url, "xxx") }.to raise_error(PhantomException::IllegalFormat, "Beside PNG format, PhantomJS supports JPEG, GIF, and PDF.")
      end
    end

    context "when url不合法" do
      it "should 抛出异常" do
        expect { Phantom.new("xxx") }.to raise_error(PhantomException::IllegalUrl, "IllegalUrl")
      end
    end
  end

  describe ".create" do
    before do
      @phantom = Phantom.new(url)
      Phantom.stub(:new).and_return(@phantom)
      File.stub(:read).and_return('')
      FileUtils.stub(:mkdir_p)
      FileUtils.stub(:mv)
    end

    describe "#genrate_image" do
      it "shoud 在shell中执行phantomjs截取网页" do
        @phantom.should_receive(:'`').with("#{Phantom::PhantomjsExec} #{Phantom::PhantomjsPath} #{url} #{File.join(Phantom::Tmp, @phantom.tmp_file_name)}").and_return("Success!\n")
        @phantom.genrate_image
      end
    end

    it "should 截取网页" do
      @phantom.should_receive(:genrate_image).and_return(true)
      Phantom.create(url: url, formate: 'jpg')
    end

    context "when 截取不成功" do
      before do
        @phantom.stub(:'`').with("#{Phantom::PhantomjsExec} #{Phantom::PhantomjsPath} #{url} #{File.join(Phantom::Tmp, @phantom.tmp_file_name)}").and_return("Erro!\n")
      end

      it "should 抛出异常" do
        expect {@phantom.genrate_image}.to raise_error(PhantomException::PhantomjsExecError, "Phantomjs execution error!")
      end

      it "should 返回{succss:0, reason: Phantomjs execution error!}" do
        expect(Phantom.create(url: url, formate: 'jpg')).to eql({success: 0, reason: "Phantomjs execution error!"})
      end
    end

    context "when 截取成功" do
      before do
        @phantom.stub(:'`').with("#{Phantom::PhantomjsExec} #{Phantom::PhantomjsPath} #{url} #{File.join(Phantom::Tmp, @phantom.tmp_file_name)}").and_return("Success!\n")
        @file_stream = double("文件流")
        File.stub(:read).with(@phantom.tmp_file_path).and_return(@file_stream)
        @phantom.stub(:md5).and_return("1a2b3123123123")
      end

      #it "should 将网页存于tmp目录下，以uuid为文件名"
      it "should 生成截取文件的MD5摘要" do
        expect(Digest::MD5).to receive(:hexdigest).with(@file_stream)
        Phantom.create(url: url, formate: 'jpg')        
      end

      it "should 创建MD5前5个字符的目录，作为最终文件存储路径" do
        expect(FileUtils).to receive(:mkdir_p).with(File.join(Phantom::Fin, "1/a/2/b/3"))
        Phantom.create(url: url, formate: 'jpg')
      end

      it "should 将临时文件，移动到最终文件存储路径" do
        expect(FileUtils).to receive(:mv).with(@phantom.tmp_file_path, @phantom.final_file_path)
        Phantom.create(url: url, formate: 'jpg')
      end

      describe "#final_url" do
        it "根据MD5生成 image url(无domain)" do
          expect(@phantom.final_url).to eql('/images/1/a/2/b/3/1a2b3123123123.jpg')
        end
      end

      it "should 返回hash{success: 1, url: '/images/3/1/7/c/8/317c86ee553826fe782fd3abcd1bbb65.jpg', path: '/RailsPro/phantom/public/images/1/a/2/b/3/1a2b3123123123.jpg' md5: '1a2b3123123123'}" do
        expect(Phantom.create(url: url, formate: 'jpg')).to eql({success: 1, url: '/images/1/a/2/b/3/1a2b3123123123.jpg', path: @phantom.final_file_path, md5: '1a2b3123123123'})
      end
    end

  end
end
