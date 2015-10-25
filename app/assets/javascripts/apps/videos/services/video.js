(function(){
'use strict';

var Video = function(VideoApi) {
  var self = this;

  self.attributes = [
    'title',
    'link',
    'start_time',
    'end_time'
  ];

  self.build = function(video) {
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

angular.module('VideoApp')
       .service('Video', Video);
}());
