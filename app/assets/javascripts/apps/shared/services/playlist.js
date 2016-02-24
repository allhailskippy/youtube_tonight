(function(){
'use strict';

var Playlist = function(PlaylistApi) {
  var self = this;

  self.attributes = [
    'id',
    'title',
  ];

  self.build = function(show) {
    return show;
  };

  /**
   * Setup
   */

  /**
   * Class methods
   */
  self.find = function(id) {
    return PlaylistApi.get({id: id}).$promise;
  };

  self.query = function(params) {
    return PlaylistApi.query(params).$promise;
  };
};

Playlist.$inject = ['PlaylistApi'];

angular.module('shared')
       .service('Playlist', Playlist);
}());
