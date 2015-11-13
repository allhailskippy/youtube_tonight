class YoutubeApi
  API_SERVICE_NAME = 'youtube'
  API_VERSION = 'v3'

  def self.get_video_info(video)
    client, youtube = get_service

    # Call the search.list method to retrieve results matching the specified query term.
    search_response = client.execute!(
      :api_method => youtube.search.list,
      :parameters => {
        :part => 'snippet',
        :q => video,
        :maxResults => 10
      }
    )

    # Parse the query string from the video
    vp = Rack::Utils.parse_nested_query(URI.parse(video).query) rescue {}

    search_results = {}
    # Add each result to the appropriate list, and then display the lists of
    # matching videos, channels, and playlists.
    search_response.data.items.each do |r|
      case r.id.kind
        when 'youtube#video'
          search_results[r.id.videoId] = {
            video_id: r.id.videoId,
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
            link: "https://www.youtube.com/v/#{r.id.videoId}"
          }
      end
    end
    search_results = self.video_lookup(search_results) if search_results.present?

    search_results.values
  end

  def self.video_lookup(search_results)
    client, youtube = get_service
    video_lookup = client.execute!(
      :api_method => youtube.videos.list,
      :parameters => {
        :part => 'contentDetails',
        :id => search_results.keys.join(",")
      }
    )
    video_lookup.data["items"].each do |v|
      duration = v["contentDetails"]["duration"]
      search_results[v["id"]].merge!({
        "duration" => duration,
        "duration_seconds" => ISO8601::Duration.new(duration).to_i
      })
    end
    search_results
  end

  def self.get_service
    client = Google::APIClient.new(
      :key => YOUTUBE_API_KEY,
      :authorization => nil,
      :application_name => 'YoutubeTonight',
      :application_version => '1.0.0'
    )
    youtube = client.discovered_api(API_SERVICE_NAME, API_VERSION)
    return client, youtube
  end
end
