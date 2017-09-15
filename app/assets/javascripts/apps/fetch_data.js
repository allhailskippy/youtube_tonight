(function() {
  'use strict';

  /**
   * @memberof main
   * @description
   *  Fetch necessary data from server-side before bootstrap the application.
   *
   *  This process gets the sessionStorage as base64 encoded.
   *    `userInfo`  from `/current_user.json`
   */
  var fetchData = function() {
    var injector = angular.injector(['ng']);
    var $http = injector.get('$http');
    var $q = injector.get('$q');
    var deferred = $q.defer();

    sessionStorage.removeItem('userInfo');
    var userInfo  = sessionStorage.getItem('userInfo');

    userInfo && deferred.resolve(true);

    $http.get('/current_user.json').then(function(result) {
      userInfo = btoa(JSON.stringify(result.data));
      sessionStorage.setItem('userInfo', userInfo);
      userInfo && deferred.resolve(true);
    }, function(error) {
      error.status == 401 && (window.location.href = '/users/sign_in');
    });

    return deferred.promise;
  };

  fetchData().then(function() {
    angular.element(document).ready(function() {
      angular.bootstrap(document, ['YTBroadcastApp']);
    });
  });
})();
