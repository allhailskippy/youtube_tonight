(function(){
'use strict';

var Video = function(VideoApi) {
  var self = this;

  self.attributes = [
    'end_time',
    'id',
    'link',
    'show_id',
    'sort_order',
    'start_time',
    'title'
  ];

  self.defaultThumbnail = 'data:image/svg+xml;charset=UTF-8,%3Csvg%20width%3D%22320%22%20height%3D%22180%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%20320%20180%22%20preserveAspectRatio%3D%22none%22%3E%3Cdefs%3E%3Cstyle%20type%3D%22text%2Fcss%22%3E%23holder_150aa833b30%20text%20%7B%20fill%3A%23AAAAAA%3Bfont-weight%3Abold%3Bfont-family%3AArial%2C%20Helvetica%2C%20Open%20Sans%2C%20sans-serif%2C%20monospace%3Bfont-size%3A16pt%20%7D%20%3C%2Fstyle%3E%3C%2Fdefs%3E%3Cg%20id%3D%22holder_150aa833b30%22%3E%3Crect%20width%3D%22320%22%20height%3D%22180%22%20fill%3D%22%23EEEEEE%22%3E%3C%2Frect%3E%3Cg%3E%3Ctext%20x%3D%2228.46875%22%20y%3D%2297.2%22%3EYoutube%20Video%20Thumbnail%3C%2Ftext%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E';

  self.build = function(video) {
    // Default image thumbnail. This looks gross, but works
    video.api_thumbnail_medium_url = video.api_thumbnail_medium_url || self.defaultThumbnail;

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
      video.video_id = yt.video_id;
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
