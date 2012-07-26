Gem::Specification.new do |s|
  s.name        = 'facebook_feed'
  s.version     = '0.0.2'
  s.date        = '2012-07-26'
  s.summary     = "Ruby bindings for Facebook feed APIs"
  s.description = "A Ruby wrapper around Facebook feed APIs. Currently, Facebook Group and Feed APIs are supported."
  s.authors     = ["Carson Tang"]
  s.email       = 'tang.carson@gmail.com'
  s.files       = ["lib/facebook_feed.rb", "lib/facebook_feed/feed_downloader.rb"]
  s.homepage    = "https://github.com/carsontang/facebook_feed"
  s.add_dependency("json")
  s.add_dependency("rest-client")
end