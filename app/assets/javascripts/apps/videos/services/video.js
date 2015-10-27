(function(){
'use strict';

var Video = function(VideoApi) {
  var self = this;

  self.attributes = [
    'end_time',
    'id',
    'link',
    'show_id',
    'start_time',
    'title',
  ];

  self.build = function(video) {
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
