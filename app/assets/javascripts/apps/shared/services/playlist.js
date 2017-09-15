(function(){
'use strict';

var Playlist = function(PlaylistApi) {
  /**
   * Setup
   */
  var self = this;

  self.attributes = [
    'id',
    'user_id',
    'api_playlist_id',
    'api_title',
    'video_count',
    'api_description',
    'api_thumbnail_default_url',
    'api_thumbnail_default_width',
    'api_thumbnail_default_height',
    'api_thumbnail_medium_url',
    'api_thumbnail_medium_width',
    'api_thumbnail_medium_height',
    'api_thumbnail_high_url',
    'api_thumbnail_high_width',
    'api_thumbnail_high_height',
    'api_thumbnail_standard_url',
    'api_thumbnail_standard_width',
    'api_thumbnail_standard_height',
    'api_thumbnail_maxres_url',
    'api_thumbnail_maxres_width',
    'api_thumbnail_maxres_height'
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

    playlist.withDefault = function(img) {
      return(!img || 0 === img.length) ? 'https://i.ytimg.com/vi/0/default.jpg' : img;
    }

    playlist.indexUrl = function(userPath) {
      return '/#' +
             (userPath ? '/users/' + playlist.user_id : '') +
             '/playlists';
    };

    playlist.videosUrl = function(userPath) {
      return '/#' +
             (userPath ? '/users/' + playlist.user_id : '') +
             '/playlists/' + playlist.id + '/videos';
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
