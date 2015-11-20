/**
 * @ngdoc service
 * @name CurrentUserApi
 * @module shared
 *
 * @description
 * This service communicates with the /current_user and associated http json endpoints
 *
 */
(function () {
'use strict';

var CurrentUserApi = function($resource) {
  var options = {
    'query': {
      method:'GET',
      isArray: false
    }
  };

  return $resource("/current_user/:id.json", null, options);
};

CurrentUserApi.$inject = ['$resource'];

angular.module('shared')
       .factory("CurrentUserApi", CurrentUserApi);
})();
