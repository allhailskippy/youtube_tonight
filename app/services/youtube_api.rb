class YoutubeApi
  API_SERVICE_NAME = 'youtube'
  API_VERSION = 'v3'

  def self.get_video_info(video)
    client, youtube = get_service

    begin
      # Call the search.list method to retrieve results matching the specified query term.
      search_response = client.execute!(
        :api_method => youtube.search.list,
        :parameters => {
          :part => 'snippet',
          :q => video, #'https://www.youtube.com/watch?v=7sNKNEfjpDQ',
          :maxResults => 1
        }
      )

      resp = {}

      # Add each result to the appropriate list, and then display the lists of
      # matching videos, channels, and playlists.
      search_response.data.items.each do |r|
        case r.id.kind
          when 'youtube#video'
            resp = {
              published_at: r.snippet.published_at,
              channel_id: r.snippet.channel_id,
              channel_title: r.snippet.channel_title,
              description: r.snippet.description,
              thumbnail_default_url: r.snippet.thumbnails.default.url,
              thumbnail_medium_url: r.snippet.thumbnails.medium.url,
              thumbnail_high_url: r.snippet.thumbnails.high.url,
              title: r.snippet.title
            }
        end
      end
    rescue Google::APIClient::TransmissionError => e
      resp = { error: e.to_s }
    end
    resp
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
