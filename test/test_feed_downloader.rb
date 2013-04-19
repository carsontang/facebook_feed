require 'test/unit'
require 'facebook_feed'

class FacebookFeedTest < Test::Unit::TestCase
  def setup
    @valid_feed_id = 1234566
    @valid_access_token = "ABCDEFG"
    @real_feed_id = 274082972642991
    @real_access_token = "BAAE3k76AcDABAFe3Jz5qZArd3GVwurFCw2Ev5ZChVbwZBxFWpXZC90tkuKyFvIZCKKskESq3bkhknVsBKO3JKXpExgYxj7ifQ65FI7xqESPAtmIcj80XqTUvoRNEQBKVG0woIXFzmZB8qyF76txgWPYh0b8NoLbToHa0i5H5ZBdYYfYJqgCQ1dIfCeUZBs5if68SgvbXISwGBgZDZD"
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
  def test_has_more_posts_when_there_are_some
    opts = {:feed_id => @valid_feed_id, :access_token => @valid_access_token}
    downloader = FacebookFeed::FeedDownloader.new(opts)
    assert downloader.has_more_posts?, "FacebookFeed::FeedDownloader should have more posts."
  end

  def test_has_more_posts_when_there_are_none
    opts = {:feed_id => @valid_feed_id, :access_token => @valid_access_token}
    downloader = FacebookFeed::FeedDownloader.new(opts)
    downloader.instance_variable_set(:@feed_urls, [])
    assert !downloader.has_more_posts?, "FacebookFeed::FeedDownloader should not have more posts."
  end

  def test_download_posts
    opts = {:feed_id => @real_feed_id, :access_token => @real_access_token}
    downloader = FacebookFeed::FeedDownloader.new(opts)
    posts = downloader.download_posts if downloader.has_more_posts?
    assert_send([posts, :any?], "posts should contains Facebook feed posts")
  end

  def test_posts_structure
    opts = {:feed_id => @real_feed_id, :access_token => @real_access_token}
    downloader = FacebookFeed::FeedDownloader.new(opts)
    posts = downloader.download_posts if downloader.has_more_posts?
    posts_keys = posts.first.keys
    keys = %w(poster message type created_time updated_time like_count comment_count comments)
    keys.map!(&:to_sym)
    keys.each { |key| assert posts_keys.include?(key) }
  end
end