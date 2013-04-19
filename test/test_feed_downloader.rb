require 'test/unit'
require 'facebook_feed'

class FacebookFeedTest < Test::Unit::TestCase
  def setup
  end

  def test_valid_feed_downloader_args
    opts = {:feed_id => 1234566, :access_token => "ABCDEFG"}
    assert_nothing_raised do
      downloader = FacebookFeed::FeedDownloader.new(opts)
    end
  end

  def test_invalid_feed_downloader_args
    opts = [:feed_id, :access_token]
    assert_raise FacebookFeed::InvalidFeedDownloaderError do
      downloader = FacebookFeed::FeedDownloader.new(opts)
    end
  end

  def test_invalid_feed_downloader_args_keys
    opts = {:feed_id => 1234566, :access_token => "ABCDEFG", :foobar => "bogus"}
    assert_raise FacebookFeed::InvalidFeedDownloaderError do
      downloader = FacebookFeed::FeedDownloader.new(opts)
    end
  end
end