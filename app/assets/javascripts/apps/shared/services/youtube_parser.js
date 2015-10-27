(function(){
'use strict';

var YoutubeParser = function(YoutubeParserApi) {
  var self = this;

  self.attributes = [
    'channel_id',
    'channel_title',
    'description',
    'end_time',
    'published_at', 
    'start_time',
    'thumbnail_default_url',
    'thumbnail_high_url',
    'thumbnail_medium_url',
    'title',
    'video_id'
  ];

  self.build = function(video) {
    return video;
  };

  self.query = function(url) {
    return YoutubeParserApi.query({ v: url }).$promise;
  };
};

YoutubeParser.$inject = ['YoutubeParserApi'];

angular.module('shared')
       .service('YoutubeParser', YoutubeParser);
}());
