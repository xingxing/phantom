require "rubygems"
require "typhoeus"
require "pry"

r = Typhoeus::Request.new(
  "localhost:4567/phantoms",
  :method => :post,
  :params => {
    :url => 'http://www.baidu.com', 
    :formate => 'jpg',
    :file_stream => 1})

hydra = Typhoeus::Hydra.hydra
hydra.queue(r)
hydra.run
r.response

f = File.open('sample.jpg', 'w')
f.write(r.response.body)

p File.read('sample.jpg').to_s == r.response.body.to_s

binding.pry


#IO.new
#p File.read('/Users/wade/RailsPro/phantom/public/images/8/9/3/8/f/8938f2704429e5125f3a749f21dcc675.jpg')
