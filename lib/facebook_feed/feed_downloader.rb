module FacebookFeed
  # TO-DO:
  # Deal with expired access tokens, which render urls in @feed_urls useless
  # Create FacebookFeed errors that are raised when FeedDownloader isn't properly initialized

  class FeedDownloader
    attr_reader :access_token, :feed_id

    # Initialize an instance of FeedDownloader like so
    # opts = { :feed_id => 1234567, :access_token => 'ABCDEFGHI' }
    # downloader = FeedDownloader.new(opts)

    def initialize(args)
      raise FacebookFeed::InvalidFeedDownloaderError, "FeedDownloader must be instantiated with a Ruby hash" unless args.is_a?(Hash)
      unless (args.keys.length == 2) and args.keys.include?(:feed_id) and args.keys.include?(:access_token)
        raise FacebookFeed::InvalidFeedDownloaderError, "FeedDownloader must be configured with a hash with two keys only: :feed_id and :access_token"
      end

      args.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end

      base_url = "https://graph.facebook.com/#{@feed_id}/feed?access_token=#{@access_token}"
      @feed_urls = []
      @feed_urls << base_url
    end

    def has_more_posts?
      @feed_urls.any?
    end

    def download_posts
      # Return an array of posts in JSON format   
      if @feed_urls.any?
        current_url = @feed_urls.shift
        begin
          content_hash = get_content_hash(current_url)
        rescue RestClient::InternalServerError => e
          raise FacebookFeed::InvalidCredentialsError,
            "Invalid Facebook Group ID or access token:\nGroup ID: #{@feed_id}\nAccess Token: #{@access_token}"
        end
        add_urls_if_any(@feed_urls, content_hash)
        extract_posts(content_hash)
      end
    end

    private
    def add_urls_if_any(feed_urls, content_hash)
      posts = content_hash["data"]
      feed_urls << content_hash["paging"]["next"] unless posts.empty?
    end

    # Returns a hash object of the JSON returned by the Facebook Graph API
    def get_content_hash(url)
      # TO-DO: Write code to authenticate server
      content = RestClient::Resource.new(
        url,
          :verify_ssl => OpenSSL::SSL::VERIFY_NONE
        # :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(File.read("cert.pem")), 
        # :ssl_client_key   =>  OpenSSL::PKey::RSA.new(File.read("key.pem"), "passphrase, if any"),
        # :ssl_ca_file      =>  "ca_certificate.pem", 
        # :verify_ssl       =>  OpenSSL::SSL::VERIFY_PEER 
        ).get
      JSON.parse(content)
    end

    # Takes in a hash object of the JSON returned by the Facebook Graph API
    # and returns an array of hash objects like the following:
    # {
    # :poster => 'Name of message poster',
    # :message => 'Message text',
    # :type => 'Type of post',
    # :created_time => 'UTC time message was created',
    # :updated_time => 'UTC time message was updated',
    # :like_count => 'Number of likes the post has',
    # :comment_count => 'Number of comments the post has',
    # :comments => ['Array of comment data']
    # }
    # 
    # A comment datum is itself as a hash as well.
    # It is like the following:
    # {
    #   :commenter => 'Name of person who made the comment',
    #   :message => 'Comment text',
    #   :created_time => 'UTC time comment was made',
    #   :like_count => 'Number of likes the comment has'
    # }

    def extract_posts(content_hash)
      posts = content_hash["data"]
      return [] if posts.nil?

      docs = []
      posts.each do |post|
        doc = {}
        doc[:poster] = post["from"]["name"]
        doc[:message] = post["message"]
        doc[:type] = post["type"]
        doc[:created_time] = post["created_time"]
        doc[:updated_time] = post["updated_time"]
        doc[:like_count] = post["likes"].nil? ? 0 : post["likes"]["count"]
        
        # Store each comment's sender, time, number of likes, and
        # the total number of comments for this post
        unless post["comments"].nil?
          doc[:comment_count] = post["comments"]["count"]
          # Check if data is not nil rather than comment count because
          # there's a Facebook bug that doesn't log all comments even
          # if comment number > 0
          unless post["comments"]["data"].nil?
            doc[:comments] = []
            comments = post["comments"]["data"]
            comments.each do |comment|
              comment_data = {}
              comment_data[:commenter] = comment["from"]["name"]
              comment_data[:message] = comment["message"]
              comment_data[:created_time] = comment["created_time"]
              comment_data[:like_count] = comment["likes"] || 0
              doc[:comments] << comment_data
            end
          end
        else
          doc[:comment_count] = 0
        end
        docs << doc
      end
      docs
    end
  end
end