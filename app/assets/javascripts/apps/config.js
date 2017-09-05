(function() {
  'use strict';

  /**
   * initialization
   * @module YTBroadcast
   * @description
   * Run it only once when the application starts
   *
   * It sets the $rootScope variables
   *   - `$location`
   *   - `$routeParams`
   *   - `currentUser`
   *   - `auth`
   */
  var runFunc = function($rootScope, $http, $routeParams, $location, $window, CurrentUser, UserInfo, Auth, User) {
    $rootScope.$location = $location;
    $rootScope.$routeParams = $routeParams;

    // Setup current user
    UserInfo.get().then(function(response) {
      var user = User.build(response.data);
      user.hasAnyRole = UserInfo.hasAnyRole;
      !Auth.currentUser && Auth.setCurrentUser(user);
      $rootScope.currentUser = user;
      $rootScope.auth = Auth.permittedTo;
      $http.defaults.headers.common['X-CSRF-TOKEN'] = response.data.xCSRFToken;
      $http.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
    });

    // Add front side authorization
    $rootScope.$on('$routeChangeStart', function(scope, next, current) {
      var permission = (next.$$route && next.$$route.permission) || undefined;
      if(angular.isString(permission) && !$rootScope.auth(permission)) {
        $window.location.href = '/unauthorized';
      }
    });
  };
  runFunc.$inject = ['$rootScope', '$http', '$routeParams', '$location', '$window', 'CurrentUser', 'UserInfo', 'Auth', 'User'];
  angular.module('YTBroadcastApp').run(runFunc);
})();