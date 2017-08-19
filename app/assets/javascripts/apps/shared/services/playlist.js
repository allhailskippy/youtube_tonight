(function(){
'use strict';

var Playlist = function(PlaylistApi) {
  /**
   * Setup
   */
  var self = this;

  self.attributes = [
    'id',
    'user_id'
  ];

  /**
   * Initialize
   */
  self.build = function(playlist) {
    // Save model to server side
    playlist.save = function() {
      var $promise;
      var saveData = {};

      //Restrict to only valid attributes
      angular.forEach(self.attributes, function(attr) {
        saveData[attr] = playlist[attr];
      });

      var params = {
        playlist: saveData
      };

      // Different calls for new vs existing
      if(playlist.id) {
        $promise = PlaylistApi.update({ id: playlist.id }, params).$promise;
      } else {
        $promise = PlaylistApi.save(params).$promise;
      }
      return $promise;
    };

    playlist.importPlaylists = function() {
      var params = {
        id: playlist.id,
        user_id: playlist.user_id
      };
      return playlist.save(params);
    };

    return playlist;
  };
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
