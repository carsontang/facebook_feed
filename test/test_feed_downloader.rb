require 'test/unit'
require 'facebook_feed'

class FacebookFeedTest < Test::Unit::TestCase
  def setup
    @valid_feed_id = 1234566
    @valid_access_token = "ABCDEFG"
  end

  # Tests for FacebookFeed::FeedDownloader initialization
  def test_valid_feed_downloader_args
    opts = {:feed_id => @valid_feed_id, :access_token => @valid_access_token}
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
    opts = {:feed_id => @valid_feed_id, :access_token => @valid_access_token, :foobar => "bogus"}
    assert_raise FacebookFeed::InvalidFeedDownloaderError do
      downloader = FacebookFeed::FeedDownloader.new(opts)
    end
  end

  # Tests for FacebookFeed::FeedDownloader public API
  def test_has_more_posts_when_there_are_none
    
  end
end