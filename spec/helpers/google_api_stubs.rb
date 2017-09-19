def stub_playlists
  # Get channel listing
  body = %{
    {
      "items": [{
        "kind": "youtube#channel",
        "id": "abc1234",
        "contentDetails": {
          "relatedPlaylists": {
            "likes": "def5678",
            "favorites": "ghi91011",
            "uploads": "jkl121314",
            "watchHistory": "HL",
            "watchLater": "WL"
          }
        }
      }]
    }
  }
  stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?maxResults=50&mine=true&part=contentDetails").
              to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

  # Return hard coded playlists
  body = %{
    {
      "kind": "youtube#playlistListResponse",
      "pageInfo": {
        "totalResults": 3,
        "resultsPerPage": 5
      },
      "items": [
        {
          "kind": "youtube#playlist",
          "id": "def5678",
          "snippet": {
            "publishedAt": "2007-09-08T13:42:56.000Z",
            "channelId": "abc1234",
            "title": "Liked videos",
            "description": "",
              "thumbnails": {
              "default": { "url": "https://i.ytimg.com/vi/2gM_MsLCPo8/default.jpg", "width": 120, "height": 90 },
              "medium": { "url": "https://i.ytimg.com/vi/2gM_MsLCPo8/mqdefault.jpg", "width": 320, "height": 180 },
              "high": { "url": "https://i.ytimg.com/vi/2gM_MsLCPo8/hqdefault.jpg", "width": 480, "height": 360 },
              "standard": { "url": "https://i.ytimg.com/vi/2gM_MsLCPo8/sddefault.jpg", "width": 640, "height": 480 },
              "maxres": { "url": "https://i.ytimg.com/vi/2gM_MsLCPo8/maxresdefault.jpg", "width": 1280, "height": 720 }
            },
            "channelTitle": "Paul Mason"
          },
          "contentDetails": {
            "itemCount": 3
          }
        },{
          "kind": "youtube#playlist",
          "id": "ghi91011",
          "snippet": {
            "publishedAt": "2013-08-29T15:06:07.000Z",
            "channelId": "abc1234",
            "title": "Favorites",
            "description": "",
            "thumbnails": {
              "default": { "url": "https://i.ytimg.com/vi/rq3yBV3e_UE/default.jpg", "width": 120, "height": 90 },
              "medium": { "url": "https://i.ytimg.com/vi/rq3yBV3e_UE/mqdefault.jpg", "width": 320, "height": 180 },
              "high": { "url": "https://i.ytimg.com/vi/rq3yBV3e_UE/hqdefault.jpg", "width": 480, "height": 360 },
              "standard": { "url": "https://i.ytimg.com/vi/rq3yBV3e_UE/sddefault.jpg", "width": 640, "height": 480 },
              "maxres": { "url": "https://i.ytimg.com/vi/rq3yBV3e_UE/maxresdefault.jpg", "width": 1280, "height": 720 }
            },
            "channelTitle": "Paul Mason"
          },
          "contentDetails": {
            "itemCount": 1
          }
        },{
          "kind": "youtube#playlist",
          "id": "jkl121314",
          "snippet": {
            "publishedAt": "1970-01-01T00:00:00.000Z",
            "channelId": "abc1234",
            "title": "Uploads from Paul Mason",
            "description": "",
            "thumbnails": {
              "default": { "url": "https://i.ytimg.com/vi/VoYyc2ycMLE/default.jpg", "width": 120, "height": 90 },
              "medium": { "url": "https://i.ytimg.com/vi/VoYyc2ycMLE/mqdefault.jpg", "width": 320, "height": 180 },
              "high": { "url": "https://i.ytimg.com/vi/VoYyc2ycMLE/hqdefault.jpg", "width": 480, "height": 360 },
              "standard": { "url": "https://i.ytimg.com/vi/VoYyc2ycMLE/sddefault.jpg", "width": 640, "height": 480 },
              "maxres": { "url": "https://i.ytimg.com/vi/VoYyc2ycMLE/maxresdefault.jpg", "width": 1280, "height": 720 }
            },
            "channelTitle": "Paul Mason"
          },
          "contentDetails": {
            "itemCount": 1
          }
        }
      ]
    }
  }
  stub_request(:get, "https://www.googleapis.com/youtube/v3/playlists?id=ghi91011,def5678,jkl121314&part=contentDetails,snippet").
              to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

  page1 = %{
    {
      "kind": "youtube#playlistListResponse",
      "nextPageToken": "nextnextnext",
      "pageInfo": {
        "totalResults": 2,
        "resultsPerPage": 1
      },
      "items": [
        {
          "kind": "youtube#playlist",
          "id": "plr1",
          "snippet": {
            "publishedAt": "2016-10-26T17:27:41.000Z",
            "channelId": "abc1234",
            "title": "LEGO Dimensions",
            "description": "",
            "thumbnails": {
              "default": { "url": "https://i.ytimg.com/vi/17jao7VkozI/default.jpg", "width": 120, "height": 90 },
              "medium": { "url": "https://i.ytimg.com/vi/17jao7VkozI/mqdefault.jpg", "width": 320, "height": 180 },
              "high": { "url": "https://i.ytimg.com/vi/17jao7VkozI/hqdefault.jpg", "width": 480, "height": 360 },
              "standard": { "url": "https://i.ytimg.com/vi/17jao7VkozI/sddefault.jpg", "width": 640, "height": 480 },
              "maxres": { "url": "https://i.ytimg.com/vi/17jao7VkozI/maxresdefault.jpg", "width": 1280, "height": 720 }
            },
            "channelTitle": "Paul Mason"
          },
          "contentDetails": {
            "itemCount": 1
          }
        }
      ]
    }
  }
  page2 = %{
    {
      "kind": "youtube#playlistListResponse",
      "pageInfo": {
        "totalResults": 2,
        "resultsPerPage": 1
      },
      "items": [
        {
          "kind": "youtube#playlist",
          "id": "plr2",
          "snippet": {
            "publishedAt": "2015-07-13T13:30:44.000Z",
            "channelId": "abc1234",
            "title": "YouTube Tonight",
            "description": "",
            "thumbnails": {
              "default": { "url": "https://i.ytimg.com/vi/r3tNjJLXME8/default.jpg", "width": 120, "height": 90 },
              "medium": { "url": "https://i.ytimg.com/vi/r3tNjJLXME8/mqdefault.jpg", "width": 320, "height": 180 },
              "high": { "url": "https://i.ytimg.com/vi/r3tNjJLXME8/hqdefault.jpg", "width": 480, "height": 360 }
            },
            "channelTitle": "Paul Mason"
          },
          "contentDetails": {
            "itemCount": 1
          }
        }
      ]
    }
  }
  stub_request(:get, "https://www.googleapis.com/youtube/v3/playlists?maxResults=50&mine=true&part=snippet,contentDetails").
              to_return(status: 200, body: page1, headers: { "content-type": "application/json; charset=UTF-8" }).times(1).then.
              to_return(status: 200, body: page2, headers: { "content-type": "application/json; charset=UTF-8" })
end

def stub_videos
  stub_playlists

  # Videos for playslist def5678
  page1 = %{
    {
      "kind": "youtube#playlistItemListResponse",
      "nextPageToken": "nextpagetoken",
      "pageInfo": {
        "totalResults": 3,
        "resultsPerPage": 2
      },
      "items": [
        {
          "kind": "youtube#playlistItem",
          "id": "a123",
          "snippet": {
            "publishedAt": "2015-04-15T12:32:43.000Z",
            "channelId": "abc1234",
            "title": "Test Video 1",
            "description": "Video description 1",
            "thumbnails": {
              "default": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/default.jpg", "width": 120, "height": 90 },
              "medium": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/mqdefault.jpg", "width": 320, "height": 180 },
              "high": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/hqdefault.jpg", "width": 480, "height": 360 },
              "standard": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/sddefault.jpg", "width": 640, "height": 480 },
              "maxres": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/maxresdefault.jpg", "width": 1280, "height": 720 }
            },
            "channelTitle": "Paul Mason",
            "playlistId": "def5678",
            "position": 0,
            "resourceId": {
              "kind": "youtube#video",
              "videoId": "a123"
            }
          }
        }, {
          "kind": "youtube#playlistItem",
          "id": "a124",
          "snippet": {
            "publishedAt": "2015-04-15T12:32:43.000Z",
            "channelId": "abc1234",
            "title": "Test Video 2",
            "description": "Video description 2",
            "thumbnails": {
              "default": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/default.jpg", "width": 120, "height": 90 },
              "medium": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/mqdefault.jpg", "width": 320, "height": 180 },
              "high": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/hqdefault.jpg", "width": 480, "height": 360 },
              "standard": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/sddefault.jpg", "width": 640, "height": 480 },
              "maxres": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/maxresdefault.jpg", "width": 1280, "height": 720 }
            },
            "channelTitle": "Paul Mason",
            "playlistId": "def5678",
            "position": 1,
            "resourceId": {
              "kind": "youtube#video",
              "videoId": "a124"
            }
          }
        }
      ]
    }
  }
  stub_request(:get, "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=50&part=snippet&playlistId=def5678").
              to_return(status: 200, body: page1, headers: { "content-type": "application/json; charset=UTF-8" })

  # To ensure pagination calls work
  page2 = %{
    {
      "kind": "youtube#playlistItemListResponse",
      "pageInfo": {
        "totalResults": 3,
        "resultsPerPage": 2
      },
      "items": [
        {
          "kind": "youtube#playlistItem",
          "id": "b234",
          "snippet": {
            "publishedAt": "2015-04-15T12:32:43.000Z",
            "channelId": "abc1234",
            "title": "Test Video 3",
            "description": "Test video description 3",
            "thumbnails": {
              "default": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/default.jpg", "width": 120, "height": 90 },
              "medium": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/mqdefault.jpg", "width": 320, "height": 180 },
              "high": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/hqdefault.jpg", "width": 480, "height": 360 },
              "standard": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/sddefault.jpg", "width": 640, "height": 480 },
              "maxres": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/maxresdefault.jpg", "width": 1280, "height": 720 }
            },
            "channelTitle": "Paul Mason",
            "playlistId": "def5678",
            "position": 2,
            "resourceId": {
              "kind": "youtube#video",
              "videoId": "b234"
            }
          }
        }
      ]
    }
  }
  stub_request(:get, "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=50&pageToken=nextpagetoken&part=snippet&playlistId=def5678").
              to_return(status: 200, body: page2, headers: { "content-type": "application/json; charset=UTF-8" })

  # Duration lookups
  body = %{
    {
      "kind": "youtube#videoListResponse",
      "pageInfo": {
        "totalResults": 2,
        "resultsPerPage": 5
      },
      "items": [
        {
          "kind": "youtube#video",
          "id": "a123",
          "contentDetails": {
            "duration": "PT1H15M15S",
            "dimension": "2d",
            "definition": "hd",
            "caption": "false",
            "licensedContent": false,
            "projection": "rectangular"
          }
        }, {
          "kind": "youtube#video",
          "id": "a124",
          "contentDetails": {
            "duration": "PT1M3S",
            "dimension": "2d",
            "definition": "hd",
            "caption": "false",
            "licensedContent": false,
            "projection": "rectangular"
          }
        }
      ]
    }
  }
  stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=a123,a124&part=contentDetails").
              to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

  body = %{
    {
      "kind": "youtube#videoListResponse",
      "pageInfo": {
        "totalResults": 1,
        "resultsPerPage": 5
      },
      "items": [
        {
          "kind": "youtube#video",
          "id": "b234",
          "contentDetails": {
            "duration": "PT5M55S",
            "dimension": "2d",
            "definition": "hd",
            "caption": "false",
            "licensedContent": false,
            "projection": "rectangular"
          }
        }
      ]
    }
  }
  stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=b234&part=contentDetails").
              to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })


  # Videos for the rest of the playslist
  ['ghi91011', 'jkl121314', 'plr1', 'plr2'].each do |pid|
    body = %{
      {
        "kind": "youtube#playlistItemListResponse",
        "pageInfo": {
          "totalResults": 1,
          "resultsPerPage": 5
        },
        "items": [
          {
            "kind": "youtube#playlistItem",
            "id": "c123#{pid}",
            "snippet": {
              "publishedAt": "2015-04-15T12:32:43.000Z",
              "channelId": "abc1234",
              "title": "Test Video 1 playlist #{pid}",
              "description": "Video description 1 playlist #{pid}",
              "thumbnails": {
                "default": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/default.jpg", "width": 120, "height": 90 },
                "medium": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/mqdefault.jpg", "width": 320, "height": 180 },
                "high": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/hqdefault.jpg", "width": 480, "height": 360 },
                "standard": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/sddefault.jpg", "width": 640, "height": 480 },
                "maxres": { "url": "https://i.ytimg.com/vi/IE9oSfHVVyo/maxresdefault.jpg", "width": 1280, "height": 720 }
              },
              "channelTitle": "Paul Mason",
              "playlistId": "#{pid}",
              "position": 0,
              "resourceId": {
                "kind": "youtube#video",
                "videoId": "c123#{pid}"
              }
            }
          }
        ]
      }
    }
    stub_request(:get, "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=50&part=snippet&playlistId=#{pid}").
                to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

    # Duration lookups
    body = %{
      {
        "kind": "youtube#videoListResponse",
        "pageInfo": {
          "totalResults": 1,
          "resultsPerPage": 5
        },
        "items": [
          {
            "kind": "youtube#video",
            "id": "c123#{pid}",
            "contentDetails": {
              "duration": "PT1M3S",
              "dimension": "2d",
              "definition": "hd",
              "caption": "false",
              "licensedContent": false,
              "projection": "rectangular"
            }
          }
        ]
      }
    }
    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=c123#{pid}&part=contentDetails").
                to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })
  end
end
