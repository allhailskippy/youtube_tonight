/**
 * @ngdoc service
 * @name YoutubeParserApi
 * @module shared
 *
 * @description
 * This service communicates with the /youtube_parser endpoints
 *
 */
(function () {
'use strict';

var YoutubeParserApi = function($resource) {
  var options = {
    'query': {
      method:'GET',
      isArray: false
    }
  };

  return $resource("/youtube_parser/:id.json", null, options);
};

YoutubeParserApi.$inject = ['$resource'];

angular.module('shared')
       .factory("YoutubeParserApi", YoutubeParserApi);
})();
