/**
 * @ngdoc service
 * @name RoleApi
 * @module shared
 *
 * @description
 * This service communicates with the /roles and associated http json endpoints
 *
 */
(function () {
'use strict';

var RoleApi = function($resource) {
  var options = {
    'query': {
      method:'GET',
      isArray: false
    },
    'update': {
      method: 'PUT'
    }
  };

  return $resource("/roles/:id.json", null, options);
};

RoleApi.$inject = ['$resource'];

angular.module('shared')
       .factory("RoleApi", RoleApi);
})();
