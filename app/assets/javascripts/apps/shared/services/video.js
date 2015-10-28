(function(){
'use strict';

var Video = function(VideoApi) {
  var self = this;

  self.attributes = [
    'api_channel_id',
    'api_channel_title',
    'api_description',
    'api_published_at',
    'api_thumbnail_default_url',
    'api_thumbnail_high_url',
    'api_thumbnail_medium_url',
    'api_title',
    'end_time',
    'id',
    'link',
    'show_id',
    'sort_order',
    'start_time',
    'title',
    'api_video_id'
  ];

  self.build = function(video) {
    // Delete video
    video.destroy = function() {
      return VideoApi.delete({id: video.id}).$promise;
    };

    // Save model to server side
    video.save = function() {
      var $promise;
      var saveData = {};

      //Restrict to only valid attributes
      angular.forEach(self.attributes, function(attr) {
        saveData[attr] = video[attr];
      });

      var params = {
        video: saveData
      };

      // Different calls for new vs existing
      if(video.id) {
        $promise = VideoApi.update({ id: video.id }, params).$promise;
      } else {
        $promise = VideoApi.save(params).$promise;
      }
      return $promise;
    };

    // Takes response from YoutubeParser and sets video attributes
    video.setFromYoutubeParser = function(yt) {
      // Set values based on lookup results
      video.title = yt.title;
      video.api_video_id = yt.video_id;
      video.start_time = yt.start_time;
      video.end_time = yt.end_time;
      video.api_published_at = yt.published_at;
      video.api_channel_id = yt.channel_id;
      video.api_channel_title = yt.channel_title;
      video.api_description = yt.description;
      video.api_thumbnail_medium_url = yt.thumbnail_medium_url;
      video.api_thumbnail_default_url = yt.thumbnail_default_url;
      video.api_thumbnail_high_url = yt.thumbnail_high_url;
      video.api_title = yt.title;
      video.link = yt.link;
    };
    return video;
  };

  self.find = function(id) {
    return VideoApi.get({id: id}).$promise;
  };

  self.query = function(params) {
    return VideoApi.query(params).$promise;
  };
};

Video.$inject = ['VideoApi'];

angular.module('shared')
       .service('Video', Video);
}());
