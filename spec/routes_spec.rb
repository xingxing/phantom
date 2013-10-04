# -*- coding: utf-8 -*-
require "spec_helper"
require "routes"

describe "Phantom Application" do
  include Rack::Test::Methods

  describe "POST /phantoms" do
    it "should 创建 phantom" do
      expect(Phantom).to receive(:create).with(url: 'http://wadexing.com', formate: 'png')
      post '/phantoms', url: 'http://wadexing.com', formate: 'png'
    end

    context "when phantom 被创建成功" do
      before { Phantom.stub(:create).and_return({success: 1, url: "/images/1/a/2/b/3/1a2b3sasad.png"}) }

      it "should 给出url" do
        post '/phantoms', url: 'http://wadexing.com', formate: 'png'
        expect(last_response.body).to eq({success: 1, url: 'http://example.org/images/1/a/2/b/3/1a2b3sasad.png'}.to_json)
      end
    end

    context "when phantom被创建失败" do
      before { Phantom.stub(:create).and_return({success: 0, reason: "Error!"}) }

      it "should 给出原因" do
        post '/phantoms', url: 'http://wadexing.com', formate: 'png'
        expect(last_response.body).to eq({success: 0, reason: "Error!"}.to_json)
      end
    end
  end

  describe "GET /phantoms/md5" do
    it "should 根据md5查找phantom" do
      expect(Phantom).to receive(:find).with('md5')
      get '/phantoms/md5'
    end

    context "when phantom被找到" do
      before { Phantom.stub(:find).and_return({success: 1, url: "/images/1/a/2/b/3/1a2b3sasad.png"}) }

      it "should 给出url" do
        get '/phantoms/md5'
        expect(last_response.body).to eq({success: 1, url: 'http://example.org/images/1/a/2/b/3/1a2b3sasad.png'}.to_json)
      end
    end

    context "when phantom没有被找到" do
      before { Phantom.stub(:find).and_return(nil) }

      it "should 返回404" do
        get '/phantoms/md5'
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq("Sorry, such file doesn't exist!")
      end
    end
  end

  describe "DELETE /phantoms/md5" do
    it "should 根据md5销毁phantom" do
      expect(Phantom).to receive(:destroy).with('md5')
      delete '/phantoms/md5'
    end

    context "when phantom被成功销毁" do
      before { Phantom.stub(:destroy).and_return(true) }

      it "should 返回success: 1" do
        delete '/phantoms/md5'
        expect(last_response.body).to eq({success: 1}.to_json)
      end
    end

    context "when phantom被销毁失败" do
      before { Phantom.stub(:destroy).and_return(nil) }

      it "should 返回404" do
        delete '/phantoms/md5'
        expect(last_response.status).to eq(404)
        expect(last_response.body).to eq("Sorry, such file doesn't exist!")
      end
    end
  end
end
