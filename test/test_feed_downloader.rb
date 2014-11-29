require 'minitest/autorun'
require 'facebook_feed'

class FacebookFeedTest < Minitest::Test
  def setup
    @valid_feed_id = 1234566
    @valid_access_token = 'ABCDEFG'
    @real_feed_id = 1501986260074649
    @real_access_token = 'CAACEdEose0cBACb9LdckZC2vsC2hC26mGZARpuycI45waVrkuG1CGy3S7DmRgBArkRRvhAhZBdNXuj5CTnGnnMbMNWlNWgTj2dEaJcIIamvZCbZBsbtMQOe7880sRNqxCHnketQWBHWaCHnBFfdnrQKvoqq9UwZAmueG8r4pUFaunx1ACgsFRLA5UBVSGiZC4QEs973TZCqaj11bRDnyCs2Lxk6VQzZCqMRMZD'
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
    assert_raises FacebookFeed::InvalidFeedDownloaderError do
      downloader = FacebookFeed::FeedDownloader.new(opts)
    end
  end

  def test_invalid_feed_downloader_args_keys
    opts = {:feed_id => @valid_feed_id, :access_token => @valid_access_token, :foobar => "bogus"}
    assert_raises FacebookFeed::InvalidFeedDownloaderError do
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
    keys.each { |key| assert posts_keys.include?(key), "A post hash should not have this key: #{key}" }
  end

  def assert_nothing_raised(*)
    yield
  end
end
