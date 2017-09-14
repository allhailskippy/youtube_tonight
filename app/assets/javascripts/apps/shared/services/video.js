(function(){
'use strict';

var Video = function(
  ConnectionHelper, VideoApi
  ) {
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
    'position',
    'start_time',
    'title',
    'api_video_id',
    'api_duration',
    'api_duration_seconds',
    'parent_id',
    'parent_type'
  ];

  self.formatAttributes = [
    {'start_time': parseInt},
    {'end_time': parseInt}
  ];

  self.build = function(video) {
    /**
     * Format attributes
     */
    angular.forEach(self.formatAttributes, function(formatter) {
      angular.forEach(formatter, function(func, attr) {
        video[attr] = func(video[attr]);
      });
    });

    /**
     * Instance Methods
     */
    // Delete video
    video.destroy = function() {
      var dispatcher = ConnectionHelper.getDispatcher();
      dispatcher.trigger('video_player.stop', {
        video: video,
        player_id: 'all'
      });

      return VideoApi.delete({id: video.id}).$promise;
    };

    video.durationStr = function() {
      var d,str = '';
      if(video.api_duration) {
        d = moment.duration(video.api_duration);
        str = d.humanize() + ' (' + d.toString().replace(/^PT/, '').toLowerCase() + ')';
      }
      return str;
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
        video: saveData,
      };
      if(video.parent_type == 'Show') {
        jQuery.merge(params, { show_id: video.parent_id });
      } else if(video.parent_type == 'Playlist') {
        jQuery.merge(params, { playlist_id: video.parent_id });
      }

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
      video.api_duration = yt.duration;
      video.api_duration_seconds = yt.duration_seconds;
      video.link = yt.link;
      return video;
    };
    return video;
  };

  /**
   * Class Methods
   */
  self.setFromYoutubeParser = function(yt, params) {
    params = params || {}
    return self.build(params).setFromYoutubeParser(yt);
  };

  self.find = function(id) {
    return VideoApi.get({id: id}).$promise;
  };

  self.query = function(params) {
    return VideoApi.query(params).$promise;
  };
};

Video.$inject = [
  'ConnectionHelper', 'VideoApi'
];

angular.module('shared')
       .service('Video', Video);
}());
