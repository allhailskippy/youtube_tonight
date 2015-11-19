/**
 * @ngdoc service
 * @name UserApi
 * @module shared
 *
 * @description
 * This service communicates with the /users and associated http json endpoints
 *
 */
(function () {
'use strict';

var UserApi = function($resource) {
  var options = {
    'query': {
      method:'GET',
      isArray: false
    },
    'update': {
      method: 'PUT'
    }
  };

  return $resource("/users/:id.json", null, options);
};

UserApi.$inject = ['$resource'];

angular.module('shared')
       .factory("UserApi", UserApi);
})();
