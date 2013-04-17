Gem::Specification.new do |s|
  s.name        = 'facebook_feed'
  s.version     = '1.0.2'
  s.date        = '2013-04-17'
  s.summary     = "Ruby bindings for Facebook feed APIs"
  s.description = "A Ruby wrapper around Facebook feed APIs. Currently, Facebook Group and Feed APIs are supported."
  s.authors     = ["Carson Tang"]
  s.email       = 'tang.carson@gmail.com'
  s.files       = ["lib/facebook_feed.rb", "lib/facebook_feed/feed_downloader.rb", "lib/facebook_feed/errors/feed_error.rb", "lib/facebook_feed/errors/invalid_credentials_error.rb"]
  s.homepage    = "https://github.com/carsontang/facebook_feed"
  s.add_dependency("json", "= 1.7.4")
  s.add_dependency("rest-client", "= 1.6.7")
end