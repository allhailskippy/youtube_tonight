/**
 * @ngdoc service
 * @name UserInfo
 * @module shared
 * @description remote data model UserInfo
 */
(function(){
  'use strict';

  var UserInfo = function($q, $window) {
    var decodedUserInfo;

    var get = function() {
      var deferred = $q.defer();
      if (decodedUserInfo) {
        console.log('Reading user info. from decodedUserInfo', decodedUserInfo);
        deferred.resolve(decodedUserInfo);
      } else if ($window.sessionStorage.getItem('userInfo')) {
        decodedUserInfo = JSON.parse(atob($window.sessionStorage.getItem('userInfo')));
        console.log('Reading user info. from sessionStorage', decodedUserInfo);
        deferred.resolve(decodedUserInfo);
      }
      return deferred.promise;
    };

    var hasAnyRole = function(roles) {
      var currentUserRoles = decodedUserInfo.roles;
      var intersection = roles.filter(function(n) {
        return currentUserRoles.indexOf(n) > -1;
      });
      return intersection.length;
    };

    return {
      get: get,
      hasAnyRole: hasAnyRole
    };
  };
  UserInfo.$inject = ['$q', '$window'];

  angular.module('shared')
         .factory('UserInfo', UserInfo);
})();

