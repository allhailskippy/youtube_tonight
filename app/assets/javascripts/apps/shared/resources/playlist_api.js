/**
 * @ngdoc service
 * @name PlaylistApi
 * @module shared
 *
 * @description
 * This service communicates with the /playlists and associated http json endpoints
 *
 */
(function () {
'use strict';

var PlaylistApi = function($resource) {
  var options = {
    'query': {
      method:'GET',
      isArray: false
    }
  };

  return $resource("/playlists/:id.json", null, options);
};

PlaylistApi.$inject = ['$resource'];

angular.module('shared')
       .factory("PlaylistApi", PlaylistApi);
})();
