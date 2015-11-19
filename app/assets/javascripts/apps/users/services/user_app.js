
(function(){
'use strict';

var UserApp = function(ApplicationConstants) {
  var self = this;
  var currentUser = {};
};

UserApp.$inject = ['ApplicationConstants'];

angular.module('UserApp')
       .service('UserApp', UserApp);
}());
