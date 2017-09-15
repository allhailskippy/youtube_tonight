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

    $rootScope.$on('$routeChangeStart', function(scope, next, current) {
      // Users awaiting authorization get sent to the requires_auth page
      if($rootScope.currentUser.requires_auth) {
        scope.preventDefault();
        $window.location.href = '/users/' + $rootScope.currentUser.id + '/requires_auth';
      }

      // Add front side authorization
      var permission = (next.$$route && next.$$route.permission) || undefined;
      if(angular.isString(permission) && !$rootScope.auth(permission)) {
        scope.preventDefault();
        $window.location.href = '/#/unauthorized';
      }

      // Add custom data from routes
      try {
        $rootScope.routeData = next.$$route.data || {};
      } catch(err) {
        $rootScope.routeData = {};
      }
      $rootScope.permission = permission;

      // Set the active menu item
      var menu = (next.$$route && next.$$route.menu) || undefined;
      if(menu) {
        var menuId = '#' + menu + '_nav li'
        angular.forEach(document.querySelectorAll('nav li.active'), function(el) {
          angular.element(el).removeClass('active');
        });
        angular.element(document.querySelector(menuId)).addClass('active');
      }
    });
  };
  runFunc.$inject = ['$rootScope', '$http', '$routeParams', '$location', '$window', 'CurrentUser', 'UserInfo', 'Auth', 'User'];
  angular.module('YTBroadcastApp').run(runFunc);
})();
