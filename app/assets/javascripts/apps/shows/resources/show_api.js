/**
 * @ngdoc service
 * @name ShowApi
 * @module ShowApp
 *
 * @description
 * This service communicates with the /shows and associated http json endpoints
 *
 */
(function () {
'use strict';

var ShowApi = function($resource) {
  var options = {
    'query': {
      method:'GET',
      isArray: false
    },
    'update': {
      method: 'PUT'
    }
  };

  return $resource("/shows/:id.json", null, options);
};

ShowApi.$inject = ['$resource'];

angular.module('ShowApp')
       .factory("ShowApi", ShowApi);
})();
