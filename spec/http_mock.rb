require "rubygems"
require "typhoeus"
require "pry"

r = Typhoeus::Request.new(
  "http://10.40.13.60:4567/phantoms",
  :method => :post,
  :proxy  => "10.40.13.253:3128",
  :params => {
    :url => 'http://www.pandai.com', 
    :formate => 'jpg'})

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
