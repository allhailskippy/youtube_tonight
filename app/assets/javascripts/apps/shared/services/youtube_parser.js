(function(){
'use strict';

var YoutubeParser = function(YoutubeParserApi) {
  var self = this;

  self.attributes = [
    'channel_id',
    'channel_title',
    'description',
    'published_at', 
    'thumbnail_default_url',
    'thumbnail_high_url',
    'thumbnail_medium_url',
    'title'
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
