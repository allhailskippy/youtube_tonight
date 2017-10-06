require 'test_helper'

class YoutubeApiServiceTest < ActiveSupport::TestCase
  def stub_list_searches
    body = %{
      {
        "kind": "youtube#searchListResponse",
        "nextPageToken": "CAIQAA",
        "regionCode": "CA",
        "pageInfo": {
          "totalResults": 1000000,
          "resultsPerPage": 10
        },
        "items": [
          {
            "kind": "youtube#searchResult",
            "id": {
              "kind": "youtube#video",
              "videoId": "abcd1234"
            },
            "snippet": {
              "publishedAt": "2014-11-22T10:31:23.000Z",
              "channelId": "aaabbbchannel",
              "title": "Test Title",
              "description": "Test Video Description",
              "thumbnails": {
                "default": { "url": "https://test.com/default.jpg", "width": 120, "height": 90 },
                "medium": { "url": "https://test.com/mqdefault.jpg", "width": 320, "height": 180 },
                "high": { "url": "https://test.com/hqdefault.jpg", "width": 480, "height": 360 }
              },
              "channelTitle": "Channel Title",
              "liveBroadcastContent": "none"
            }
          },
          {
            "kind": "youtube#searchResult",
            "id": {
              "kind": "youtube#video",
              "videoId": "aabbcc-12x"
            },
            "snippet": {
              "publishedAt": "2015-04-10T19:36:16.000Z",
              "channelId": "ccddchannel",
              "title": "A Test Title 2",
              "description": "Video description goes here",
              "thumbnails": {
                "default": { "url": "https://example.com/default.jpg", "width": 120, "height": 90 },
                "medium": { "url": "https://example.com/mqdefault.jpg", "width": 320, "height": 180 },
                "high": { "url": "https://example.com/hqdefault.jpg", "width": 480, "height": 360 }
              },
              "channelTitle": "Channel Title 2",
              "liveBroadcastContent": "none"
            }
          }
        ]
      }
    }
    stub_request(:get, "https://www.googleapis.com/youtube/v3/search?maxResults=10&part=snippet&q=test").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })
  end

  def stub_list_searches_ignored_kind
    body = %{
      {
        "items": [
          {
            "id": {
              "kind": "youtube#wrong",
              "videoId": "abcd1234"
            }
          },{
            "id": {
              "kind": "youtube#wrong_kind",
              "videoId": "aabbcc-12x"
            }
          }
        ]
      }
    }
    stub_request(:get, "https://www.googleapis.com/youtube/v3/search?maxResults=10&part=snippet&q=test").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })
  end

  def stub_duration
    stub_list_searches
    body = %{
      {
        "kind": "youtube#videoListResponse",
        "pageInfo": {
          "totalResults": 2,
          "resultsPerPage": 2
        },
        "items": [
          {
            "kind": "youtube#video",
            "id": "abcd1234",
            "contentDetails": {
              "duration": "PT6M4S",
              "dimension": "2d",
              "definition": "hd",
              "caption": "false",
              "licensedContent": true,
              "projection": "rectangular"
            }
          },
          {
            "kind": "youtube#video",
            "id": "aabbcc-12x",
            "contentDetails": {
              "duration": "PT5M",
              "dimension": "2d",
              "definition": "hd",
              "caption": "false",
              "licensedContent": true,
              "projection": "rectangular"
            }
          }
        ]
      }
    }
    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=abcd1234,aabbcc-12x&part=contentDetails").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })
  end

  test 'gets video info' do
    stub_list_searches
    stub_duration
    user = create(:user)

    response = YoutubeApi.get_video_info('test', user)
    expected = [
      {
        video_id: "abcd1234",
        start_time: nil,
        end_time: nil,
        published_at: 'Sat, 22 Nov 2014 10:31:23 +0000'.to_datetime,
        channel_id: "aaabbbchannel",
        channel_title: "Channel Title",
        description: "Test Video Description",
        thumbnail_default_url: "https://test.com/default.jpg",
        thumbnail_medium_url: "https://test.com/mqdefault.jpg",
        thumbnail_high_url: "https://test.com/hqdefault.jpg",
        title: "Test Title",
        link: "https://www.youtube.com/v/abcd1234",
        duration: "PT6M4S",
        duration_seconds: 364.0
      }.with_indifferent_access, {
        video_id: "aabbcc-12x",
        start_time: nil,
        end_time: nil,
        published_at: 'Fri, 10 Apr 2015 19:36:16 +0000'.to_datetime,
        channel_id: "ccddchannel",
        channel_title: "Channel Title 2",
        description: "Video description goes here",
        thumbnail_default_url: "https://example.com/default.jpg",
        thumbnail_medium_url: "https://example.com/mqdefault.jpg",
        thumbnail_high_url: "https://example.com/hqdefault.jpg",
        title: "A Test Title 2",
        link: "https://www.youtube.com/v/aabbcc-12x",
        duration: "PT5M",
        duration_seconds: 300.0
      }.with_indifferent_access
    ]
    assert_equal expected, response
  end

  test 'ignores wrong kind of search results' do
    stub_list_searches_ignored_kind
    user = create(:user)
    response = YoutubeApi.get_video_info('test', user)

    assert_equal [], response
  end

  def stub_playlists
    # Playlist ids for hardcoded playlists
    body = %{
      {
        "kind": "youtube#channelListResponse",
        "pageInfo": {
          "totalResults": 1,
          "resultsPerPage": 1
        },
        "items": [
          {
            "kind": "youtube#channel",
            "id": "channelid-abc123",
            "contentDetails": {
              "relatedPlaylists": {
                "likes": "abcd1234",
                "favorites": "abcd1235",
                "uploads": "abcd1236",
                "watchHistory": "HL",
                "watchLater": "WL"
              }
            }
          }
        ]
      }
    }
    stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=contentDetails").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

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
            "id": "abcd1234",
            "snippet": {
              "publishedAt": "2007-09-08T13:42:56.000Z",
              "channelId": "channel123",
              "title": "Liked videos",
              "description": "Liked videos description",
              "thumbnails": {
                "default": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/default.jpg", "width": 120, "height": 90 },
                "medium": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/mqdefault.jpg", "width": 320, "height": 180 },
                "high": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/hqdefault.jpg", "width": 480, "height": 360 },
                "standard": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/sddefault.jpg", "width": 640, "height": 480 }
              },
              "channelTitle": "Paul Mason"
            },
            "contentDetails": {
              "itemCount": 4476
            }
          },
          {
            "kind": "youtube#playlist",
            "id": "abcd1235",
            "snippet": {
              "publishedAt": "2013-08-29T15:06:07.000Z",
              "channelId": "channel123",
              "title": "Favorites",
              "description": "Favorite videos description",
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
              "itemCount": 1712
            }
          },
          {
            "kind": "youtube#playlist",
            "id": "abcd1236",
            "snippet": {
              "publishedAt": "1970-01-01T00:00:00.000Z",
              "channelId": "channel123",
              "title": "Uploads from Paul Mason",
              "description": "Uploads description",
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
              "itemCount": 232
            }
          }
        ]
      }
    }

    # Lookup playlist info for hardcoded playlists now that we've got the id
    stub_request(:get, "https://www.googleapis.com/youtube/v3/playlists?id=abcd1235,abcd1234,abcd1236&part=contentDetails,snippet").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

    body = %{
      {
        "kind": "youtube#playlistListResponse",
        "nextPageToken": "CAIQAA",
        "pageInfo": {
          "totalResults": 19,
          "resultsPerPage": 2
        },
        "items": [
          {
            "kind": "youtube#playlist",
            "id": "playlistid1",
            "snippet": {
              "publishedAt": "2016-10-26T17:27:41.000Z",
              "channelId": "channelid1",
              "title": "Playlist Test Title 1",
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
              "itemCount": 23
            }
          }, {
            "kind": "youtube#playlist",
            "id": "playlistid2",
            "snippet": {
              "publishedAt": "2015-07-13T13:30:44.000Z",
              "channelId": "channelid1",
              "title": "Playlist Test Title 2",
              "description": "",
              "thumbnails": {
                "default": { "url": "https://i.ytimg.com/vi/r3tNjJLXME8/default.jpg", "width": 120, "height": 90 },
                "medium": { "url": "https://i.ytimg.com/vi/r3tNjJLXME8/mqdefault.jpg", "width": 320, "height": 180 },
                "high": { "url": "https://i.ytimg.com/vi/r3tNjJLXME8/hqdefault.jpg", "width": 480, "height": 360 }
              },
              "channelTitle": "Paul Mason"
            },
            "contentDetails": {
              "itemCount": 42
            }
          }
        ]
      }
    }
    # Get all the manually created playlists
    stub_request(:get, "https://www.googleapis.com/youtube/v3/playlists?maxResults=50&mine=true&part=snippet,contentDetails").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

    # Also get a second page
    body = %{
      {
        "kind": "youtube#playlistListResponse",
        "pageInfo": {
          "totalResults": 19,
          "resultsPerPage": 2
        },
        "items": [
          {
            "kind": "youtube#playlist",
            "id": "playlistid3",
            "snippet": {
              "publishedAt": "2016-10-26T17:27:41.000Z",
              "channelId": "channelid3",
              "title": "Playlist Test Title 3",
              "description": "This is a description",
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
              "itemCount": 23
            }
          }
        ]
      }
    }
    # Get all the manually created playlists
    stub_request(:get, "https://www.googleapis.com/youtube/v3/playlists?maxResults=50&mine=true&part=snippet,contentDetails&pageToken=CAIQAA").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })
  end

  test 'gets playlists' do
    stub_playlists
    user = create(:user)
    response = YoutubeApi.get_playlists(user)

    # Verify Liked videos
    playlist = response["abcd1234"]
    assert_equal user.id, playlist[:user_id]
    assert_equal "abcd1234", playlist[:playlist_id]
    assert_equal "Liked videos", playlist[:title]
    assert_equal 4476, playlist[:video_count]
    assert_equal "Liked videos description", playlist[:description],
    thumbnails = playlist[:thumbnails]
    assert_equal "https://i.ytimg.com/vi/OLxNua1M0lk/default.jpg", thumbnails.default.url
    assert_equal 120, thumbnails.default.width
    assert_equal 90, thumbnails.default.height
    assert_equal "https://i.ytimg.com/vi/OLxNua1M0lk/mqdefault.jpg", thumbnails.medium.url
    assert_equal 320, thumbnails.medium.width
    assert_equal 180, thumbnails.medium.height
    assert_equal "https://i.ytimg.com/vi/OLxNua1M0lk/hqdefault.jpg", thumbnails.high.url
    assert_equal 480, thumbnails.high.width
    assert_equal 360, thumbnails.high.height
    assert_equal "https://i.ytimg.com/vi/OLxNua1M0lk/sddefault.jpg", thumbnails.standard.url
    assert_equal 640, thumbnails.standard.width
    assert_equal 480, thumbnails.standard.height
    assert thumbnails.maxres.blank?

    # Verify favourites
    playlist = response["abcd1235"]
    assert_equal user.id, playlist[:user_id]
    assert_equal "abcd1235", playlist[:playlist_id]
    assert_equal "Favorites", playlist[:title]
    assert_equal 1712, playlist[:video_count]
    assert_equal "Favorite videos description", playlist[:description],
    thumbnails = playlist[:thumbnails]
    assert_equal "https://i.ytimg.com/vi/rq3yBV3e_UE/default.jpg", thumbnails.default.url
    assert_equal 120, thumbnails.default.width
    assert_equal 90, thumbnails.default.height
    assert_equal "https://i.ytimg.com/vi/rq3yBV3e_UE/mqdefault.jpg", thumbnails.medium.url
    assert_equal 320, thumbnails.medium.width
    assert_equal 180, thumbnails.medium.height
    assert_equal "https://i.ytimg.com/vi/rq3yBV3e_UE/hqdefault.jpg", thumbnails.high.url
    assert_equal 480, thumbnails.high.width
    assert_equal 360, thumbnails.high.height
    assert_equal "https://i.ytimg.com/vi/rq3yBV3e_UE/sddefault.jpg", thumbnails.standard.url
    assert_equal 640, thumbnails.standard.width
    assert_equal 480, thumbnails.standard.height
    assert_equal "https://i.ytimg.com/vi/rq3yBV3e_UE/maxresdefault.jpg", thumbnails.maxres.url
    assert_equal 1280, thumbnails.maxres.width
    assert_equal 720, thumbnails.maxres.height

    # Verify Uploads
    playlist = response["abcd1236"]
    assert_equal user.id, playlist[:user_id]
    assert_equal "abcd1236", playlist[:playlist_id]
    assert_equal "Uploads from Paul Mason", playlist[:title]
    assert_equal 232, playlist[:video_count]
    assert_equal "Uploads description", playlist[:description],
    thumbnails = playlist[:thumbnails]
    assert_equal "https://i.ytimg.com/vi/VoYyc2ycMLE/default.jpg", thumbnails.default.url
    assert_equal 120, thumbnails.default.width
    assert_equal 90, thumbnails.default.height
    assert_equal "https://i.ytimg.com/vi/VoYyc2ycMLE/mqdefault.jpg", thumbnails.medium.url
    assert_equal 320, thumbnails.medium.width
    assert_equal 180, thumbnails.medium.height
    assert_equal "https://i.ytimg.com/vi/VoYyc2ycMLE/hqdefault.jpg", thumbnails.high.url
    assert_equal 480, thumbnails.high.width
    assert_equal 360, thumbnails.high.height
    assert_equal "https://i.ytimg.com/vi/VoYyc2ycMLE/sddefault.jpg", thumbnails.standard.url
    assert_equal 640, thumbnails.standard.width
    assert_equal 480, thumbnails.standard.height
    assert_equal "https://i.ytimg.com/vi/VoYyc2ycMLE/maxresdefault.jpg", thumbnails.maxres.url
    assert_equal 1280, thumbnails.maxres.width
    assert_equal 720, thumbnails.maxres.height


    # Verify Playlist 1
    playlist = response["playlistid1"]
    assert_equal user.id, playlist[:user_id]
    assert_equal "playlistid1", playlist[:playlist_id]
    assert_equal "Playlist Test Title 1", playlist[:title]
    assert_equal 23, playlist[:video_count]
    assert playlist[:description].blank?
    thumbnails = playlist[:thumbnails]
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/default.jpg", thumbnails.default.url
    assert_equal 120, thumbnails.default.width
    assert_equal 90, thumbnails.default.height
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/mqdefault.jpg", thumbnails.medium.url
    assert_equal 320, thumbnails.medium.width
    assert_equal 180, thumbnails.medium.height
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/hqdefault.jpg", thumbnails.high.url
    assert_equal 480, thumbnails.high.width
    assert_equal 360, thumbnails.high.height
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/sddefault.jpg", thumbnails.standard.url
    assert_equal 640, thumbnails.standard.width
    assert_equal 480, thumbnails.standard.height
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/maxresdefault.jpg", thumbnails.maxres.url
    assert_equal 1280, thumbnails.maxres.width
    assert_equal 720, thumbnails.maxres.height

    # Verify Playlist 2
    playlist = response["playlistid2"]
    assert_equal user.id, playlist[:user_id]
    assert_equal "playlistid2", playlist[:playlist_id]
    assert_equal "Playlist Test Title 2", playlist[:title]
    assert_equal 42, playlist[:video_count]
    assert playlist[:description].blank?
    thumbnails = playlist[:thumbnails]
    assert_equal "https://i.ytimg.com/vi/r3tNjJLXME8/default.jpg", thumbnails.default.url
    assert_equal 120, thumbnails.default.width
    assert_equal 90, thumbnails.default.height
    assert_equal "https://i.ytimg.com/vi/r3tNjJLXME8/mqdefault.jpg", thumbnails.medium.url
    assert_equal 320, thumbnails.medium.width
    assert_equal 180, thumbnails.medium.height
    assert_equal "https://i.ytimg.com/vi/r3tNjJLXME8/hqdefault.jpg", thumbnails.high.url
    assert_equal 480, thumbnails.high.width
    assert_equal 360, thumbnails.high.height
    assert thumbnails.standard.blank?
    assert thumbnails.maxres.blank?

    # Verify Playlist 3
    playlist = response["playlistid3"]
    assert_equal user.id, playlist[:user_id]
    assert_equal "playlistid3", playlist[:playlist_id]
    assert_equal "Playlist Test Title 3", playlist[:title]
    assert_equal 23, playlist[:video_count]
    assert_equal "This is a description", playlist[:description]
    thumbnails = playlist[:thumbnails]
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/default.jpg", thumbnails.default.url
    assert_equal 120, thumbnails.default.width
    assert_equal 90, thumbnails.default.height
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/mqdefault.jpg", thumbnails.medium.url
    assert_equal 320, thumbnails.medium.width
    assert_equal 180, thumbnails.medium.height
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/hqdefault.jpg", thumbnails.high.url
    assert_equal 480, thumbnails.high.width
    assert_equal 360, thumbnails.high.height
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/sddefault.jpg", thumbnails.standard.url
    assert_equal 640, thumbnails.standard.width
    assert_equal 480, thumbnails.standard.height
    assert_equal "https://i.ytimg.com/vi/17jao7VkozI/maxresdefault.jpg", thumbnails.maxres.url
    assert_equal 1280, thumbnails.maxres.width
    assert_equal 720, thumbnails.maxres.height
  end

  def stubs_videos_for_playlist
    # Get page 1
    body = %{
      {
        "kind": "youtube#playlistItemListResponse",
        "nextPageToken": "nextpagetoken",
        "pageInfo": {
          "totalResults": 4476,
          "resultsPerPage": 2
        },
        "items": [
          {
            "kind": "youtube#playlistItem",
            "id": "videoid1",
            "snippet": {
              "publishedAt": "2017-10-05T19:13:47.000Z",
              "channelId": "channelid1",
              "title": "Video Title 1",
              "description": "Video description 1",
              "thumbnails": {
                "default": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/default.jpg", "width": 120, "height": 90 },
                "medium": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/mqdefault.jpg", "width": 320, "height": 180 },
                "high": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/hqdefault.jpg", "width": 480, "height": 360 },
                "standard": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/sddefault.jpg", "width": 640, "height": 480 }
              },
              "channelTitle": "Paul Mason",
              "playlistId": "abcdefg",
              "position": 0,
              "resourceId": {
                "kind": "youtube#video",
                "videoId": "videoid1"
              }
            }
          }, {
            "kind": "youtube#playlistItem",
            "id": "videoid2",
            "snippet": {
              "publishedAt": "2017-10-05T17:09:13.000Z",
              "channelId": "channelid2",
              "title": "Video Title 2",
              "description": "Video description 2",
              "thumbnails": {
                "default": { "url": "https://i.ytimg.com/vi/VCrljh4cDt4/default.jpg", "width": 120, "height": 90 },
                "medium": { "url": "https://i.ytimg.com/vi/VCrljh4cDt4/mqdefault.jpg", "width": 320, "height": 180 },
                "high": { "url": "https://i.ytimg.com/vi/VCrljh4cDt4/hqdefault.jpg", "width": 480, "height": 360 },
                "standard": { "url": "https://i.ytimg.com/vi/VCrljh4cDt4/sddefault.jpg", "width": 640, "height": 480 },
                "maxres": { "url": "https://i.ytimg.com/vi/VCrljh4cDt4/maxresdefault.jpg", "width": 1280, "height": 720 }
              },
              "channelTitle": "Paul Mason",
              "playlistId": "abcdeft",
              "position": 1,
              "resourceId": {
                "kind": "youtube#video",
                "videoId": "videoid2"
              }
            }
          }
        ]
      }
    }
    stub_request(:get, "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=50&part=snippet&playlistId=abcdefg").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

    # Get more details about the videos
    body = %{
      {
        "kind": "youtube#videoListResponse",
        "pageInfo": {
          "totalResults": 2,
          "resultsPerPage": 2
        },
        "items": [
          {
            "kind": "youtube#video",
            "id": "videoid1",
            "contentDetails": {
              "duration": "PT8M27S",
              "dimension": "2d",
              "definition": "hd",
              "caption": "false",
              "licensedContent": true,
              "projection": "rectangular"
            }
          },{
            "kind": "youtube#video",
            "id": "videoid2",
            "contentDetails": {
              "duration": "PT4M4S",
              "dimension": "2d",
              "definition": "hd",
              "caption": "false",
              "licensedContent": true,
              "projection": "rectangular"
            }
          }
        ]
      }
    }    

    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=videoid1,videoid2&part=contentDetails").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

    # Get page 2
    body = %{
      {
        "kind": "youtube#playlistItemListResponse",
        "pageInfo": {
          "totalResults": 4476,
          "resultsPerPage": 2
        },
        "items": [
          {
            "kind": "youtube#playlistItem",
            "id": "videoid3",
            "snippet": {
              "publishedAt": "2017-10-05T19:13:47.000Z",
              "channelId": "channelid1",
              "title": "Video Title 3",
              "description": "Video description 3",
              "thumbnails": {
                "default": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/default.jpg", "width": 120, "height": 90 },
                "medium": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/mqdefault.jpg", "width": 320, "height": 180 },
                "high": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/hqdefault.jpg", "width": 480, "height": 360 },
                "standard": { "url": "https://i.ytimg.com/vi/OLxNua1M0lk/sddefault.jpg", "width": 640, "height": 480 }
              },
              "channelTitle": "Paul Mason",
              "playlistId": "abcdefg",
              "position": 2,
              "resourceId": {
                "kind": "youtube#video",
                "videoId": "videoid3"
              }
            }
          }
        ]
      }
    }
    stub_request(:get, "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=50&pageToken=nextpagetoken&part=snippet&playlistId=abcdefg").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })

    # Get more details about the videos
    body = %{
      {
        "kind": "youtube#videoListResponse",
        "pageInfo": {
          "totalResults": 2,
          "resultsPerPage": 2
        },
        "items": [
          {
            "kind": "youtube#video",
            "id": "videoid3",
            "contentDetails": {
              "duration": "PT4M13S",
              "dimension": "2d",
              "definition": "hd",
              "caption": "false",
              "licensedContent": true,
              "projection": "rectangular"
            }
          }
        ]
      }
    }    

    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=videoid3&part=contentDetails").
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })
  end

  test 'gets videos for a playlist' do
    stubs_videos_for_playlist
    user = create(:user)
    playlist = create(:playlist, api_playlist_id: 'abcdefg', user: user)

    response = YoutubeApi.get_videos_for_playlist(playlist.api_playlist_id, user)
    expected = [
      {
        video_id: "videoid1",
        title: "Video Title 1",
        thumbnail_medium_url: "https://i.ytimg.com/vi/OLxNua1M0lk/mqdefault.jpg",
        thumbnail_default_url: "https://i.ytimg.com/vi/OLxNua1M0lk/default.jpg",
        thumbnail_high_url: "https://i.ytimg.com/vi/OLxNua1M0lk/hqdefault.jpg",
        position: 0,
        published_at: "Thu, 05 Oct 2017 19:13:47 +0000".to_datetime,
        channel_id: "channelid1",
        channel_title: "Paul Mason",
        description: "Video description 1",
        duration: "PT8M27S",
        duration_seconds: 507.0
      }.with_indifferent_access, {
        video_id: "videoid2",
        title: "Video Title 2",
        thumbnail_medium_url: "https://i.ytimg.com/vi/VCrljh4cDt4/mqdefault.jpg",
        thumbnail_default_url: "https://i.ytimg.com/vi/VCrljh4cDt4/default.jpg",
        thumbnail_high_url: "https://i.ytimg.com/vi/VCrljh4cDt4/hqdefault.jpg",
        position: 1,
        published_at: "Thu, 05 Oct 2017 17:09:13 +0000".to_datetime,
        channel_id: "channelid2",
        channel_title: "Paul Mason",
        description: "Video description 2",
        duration: "PT4M4S",
        duration_seconds: 244.0
      }.with_indifferent_access, {
        video_id: "videoid3",
        title: "Video Title 3",
        thumbnail_medium_url: "https://i.ytimg.com/vi/OLxNua1M0lk/mqdefault.jpg",
        thumbnail_default_url: "https://i.ytimg.com/vi/OLxNua1M0lk/default.jpg",
        thumbnail_high_url: "https://i.ytimg.com/vi/OLxNua1M0lk/hqdefault.jpg",
        position: 2,
        published_at: "Thu, 05 Oct 2017 19:13:47 +0000".to_datetime,
        channel_id: "channelid1",
        channel_title: "Paul Mason",
        description: "Video description 3",
        duration: "PT4M13S",
        duration_seconds: 253.0
      }.with_indifferent_access
    ]
    assert_equal expected, response
  end

  test 'gets duration' do
    stub_duration
    user = create(:user)
    response = YoutubeApi.get_duration("abcd1234,aabbcc-12x", user)
    expected = {
     "abcd1234": {
       duration: "PT6M4S",
       duration_seconds: 364.0
      },
      "aabbcc-12x": {
        duration: "PT5M",
        duration_seconds: 300.0
      }
    }.with_indifferent_access
    assert_equal expected, response
  end
end
