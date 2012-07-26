module FacebookFeed
  # TO-DO:
  # Deal with expired access tokens, which render urls in @feed_urls useless
  class FeedDownloader
    def initialize(feed_id, access_token)
      base_url = "https://graph.facebook.com/#{feed_id}/feed?access_token=#{access_token}"
      @feed_urls = []
      @feed_urls << base_url
    end

    def has_more_posts?
      !@feed_urls.empty?
    end

    def download_posts
      # Return an array of posts in JSON format   
      unless @feed_urls.empty?
        current_url = @feed_urls.shift
        content_hash = get_content_hash(current_url)
        add_urls_if_any(@feed_urls, content_hash)
        extract_posts(content_hash)
      end
    end

    private
    def add_urls_if_any(feed_urls, content_hash)
      posts = content_hash["data"]
      feed_urls << content_hash["paging"]["next"] unless posts.empty?
    end

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
        unless post["likes"].nil?
          doc[:like_count] = post["likes"]["count"]
        else
          doc[:like_count] = 0
        end
        
        # Store each comment's sender, time, number of likes, and
        # the total number of comments for this post
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
            if comment["likes"].nil?
              comment_data[:like_count] = 0
            else
              comment_data[:like_count] = comment["likes"]
            end
            doc[:comments].push(comment_data)
          end
        end
        docs << doc
      end
      docs
    end
  end
end