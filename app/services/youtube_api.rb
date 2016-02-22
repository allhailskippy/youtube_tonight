class YoutubeApi
  def self.get_video_info(video)
    client = get_service

    # Call the search.list method to retrieve results matching the specified query term.
    search_response = client.list_searches('snippet', q: video, max_results: 10)

    # Parse the query string from the video
    vp = Rack::Utils.parse_nested_query(URI.parse(video).query) rescue {}

    search_results = {}
    # Add each result to the appropriate list, and then display the lists of
    # matching videos, channels, and playlists.
    search_response.items.each do |r|
      case r.id.kind
        when 'youtube#video'
          search_results[r.id.video_id] = {
            video_id: r.id.video_id,
            start_time: vp["t"] ? vp["t"] : vp["start"],
            end_time: vp["end"],
            published_at: r.snippet.published_at,
            channel_id: r.snippet.channel_id,
            channel_title: r.snippet.channel_title,
            description: r.snippet.description,
            thumbnail_default_url: r.snippet.thumbnails.default.url,
            thumbnail_medium_url: r.snippet.thumbnails.medium.url,
            thumbnail_high_url: r.snippet.thumbnails.high.url,
            title: r.snippet.title,
            link: "https://www.youtube.com/v/#{r.id.video_id}"
          }
      end
    end
    search_results = self.video_lookup(search_results) if search_results.present?

    search_results.values
  end

  def self.video_lookup(search_results)
    client = get_service

    lookup = client.list_videos('contentDetails', {id: search_results.keys.join(",") })

    lookup.items.each do |v|
      duration = v.content_details.duration
      search_results[v.id].merge!({
        "duration" => duration,
        "duration_seconds" => ISO8601::Duration.new(duration).to_i
      })
    end
    search_results
  end

  def self.get_service(user = nil)
    client = Google::Apis::YoutubeV3::YouTubeService.new
      client.authorization = Signet::OAuth2::Client.new(
        authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
        client_id: GOOGLE_CLIENT_ID,
        client_secret: GOOGLE_CLIENT_SECRET
      )
      client.authorization.access_token = Authorization.current_user.auth_hash
#      client.authorization.refresh_token = refresh_token if refresh_token
    return client
  end
end
