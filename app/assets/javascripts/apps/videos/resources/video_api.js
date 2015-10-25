/**
 * @ngdoc service
 * @name VideoApi
 * @module VideoApp
 *
 * @description
 * This service communicates with the /videos and associated http json endpoints
 *
 */
(function () {
'use strict';

var VideoApi = function($resource) {
  var options = {
    'query': {
      method:'GET',
      isArray: false
    }
  };

  return $resource("/videos/:id.json", null, options);
};

VideoApi.$inject = ['$resource'];

angular.module('VideoApp')
       .factory("VideoApi", VideoApi);
})();
