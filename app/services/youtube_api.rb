class YoutubeApi
  def self.get_video_info(video, user)
    client = get_service(user)

    # Call the search.list method to retrieve results matching the specified query term.
    search_response = client.list_searches('snippet', q: video, max_results: 10)

    # Parse the query string from the video
    vp = Rack::Utils.parse_nested_query(URI.parse(video).query) rescue {}

    search_results = {}.with_indifferent_access
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

    if search_results.present?
      self.get_duration(search_results.keys.join(","), user).each do |video_id, duration|
        search_results[video_id].merge!(duration)
      end
    end

    search_results.values
  end

  def self.get_playlists(user)
    client = get_service(user)

    # Get list of playlists
    search_response = client.list_channels('contentDetails', mine: true)

    # This ugly mess of code grab select items from the channels related playlist
    # section, and associates it with the playlist id for use in video lookups
    related_playlists = search_response.items.first.content_details.related_playlists

    # Start by collecting the ids of the hard coded playlists
    hc_list = [:favorites, :likes, :uploads]
    ids = hc_list.collect{|p| related_playlists.send(p) rescue nil}.uniq.join(',')

    # Pull full details about the hard coded lists
    search_response = client.list_playlists('contentDetails,snippet', id: ids)
    playlists = {}
    search_response.items.each do |item|
      playlist = {
        title: item.snippet.title,
        video_count: item.content_details.item_count,
        description: item.snippet.description,
        thumbnails: item.snippet.thumbnails
      }
      playlists[item.id] = playlist
    end

    # Get full list of playlists
    next_page_token = nil

    ret = {}

    loop do
      search_response = client.list_playlists('snippet,contentDetails', mine: true, max_results: 50, page_token: next_page_token)
      search_response.items.each do |item|
        playlist = {
          title: item.snippet.title,
          video_count: item.content_details.item_count,
          description: item.snippet.description,
          thumbnails: item.snippet.thumbnails
        }
        playlists[item.id] = playlist
      end

      next_page_token = search_response.next_page_token
      break if next_page_token.blank?
    end

    playlists.each do |playlist_id, playlist|
      next_page_token = nil
      ret[playlist_id] = {
        user_id: user.id,
        playlist_id: playlist_id,
        title: playlist[:title],
        video_count: playlist[:video_count],
        description: playlist[:description],
        thumbnails: playlist[:thumbnails]
      }.with_indifferent_access
    end
    ret
  end

  def self.get_videos_for_playlist(playlist_id, user)
    client = get_service(user)
    next_page_token= nil

    videos = {}
    begin
      loop do
        # Lookup items from favourites list
        search_response = client.list_playlist_items('snippet', {
          playlist_id: playlist_id,
          max_results: 50,
          page_token: next_page_token
        })

        video_ids = []
        search_response.items.each do |item|
          video = item.snippet

          # Get the video id
          video_id = video.resource_id.video_id

          # Build a list of video ids to bulk lookup duration
          video_ids << video_id

          # Thumbnails
          thumbs = video.thumbnails

          # Video object
          videos[video_id] = {
            video_id: video_id,
            title: video.title,
            thumbnail_medium_url: thumbs.try(:medium).try(:url),
            thumbnail_default_url: thumbs.try(:default).try(:url),
            thumbnail_high_url: thumbs.try(:high).try(:url),
            position: video.position,
            published_at: video.published_at,
            channel_id: video.channel_id,
            channel_title: video.channel_title,
            description: video.description
          }.with_indifferent_access
        end

        self.get_duration(video_ids.join(','), user).each do |video_id, duration|
          videos[video_id].merge!(duration)
        end

        next_page_token = search_response.next_page_token
        break if next_page_token.blank?
      end
    rescue Exception => e
      NewRelic::Agent.notice_error(e)
      raise
    end

    # Return videos if there are any
    videos.values
  end

  # Get the duration of a selected set of videos.
  # Passes in a list of video_ids to reduce the number
  # of API calls made
  def self.get_duration(video_ids, user)
    client = get_service(user)

    lookup = client.list_videos('contentDetails', {id: video_ids })

    ret = {}.with_indifferent_access
    lookup.items.each do |v|
      duration = v.content_details.duration
      ret[v.id] = {
        duration: duration,
        duration_seconds: ISO8601::Duration.new(duration).to_seconds
      }.with_indifferent_access
    end
    ret
  end

  # Creates the client that facilitates communication between
  # this app and the YouTube API
  def self.get_service(user)
    client = Google::Apis::YoutubeV3::YouTubeService.new
    client.authorization = Signet::OAuth2::Client.new(
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      client_id: GOOGLE_CLIENT_ID,
      client_secret: GOOGLE_CLIENT_SECRET
    )
    client.authorization.access_token = user.get_token
    client.authorization.expires_in = (user.expires_at - Time.now.to_i)
    return client
  end
end
