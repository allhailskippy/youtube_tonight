/**
 * @ngdoc controller
 * @name IndexCtrl
 *
 * @description Controller for the show index page 
 */
(function() {
  "use strict";

var IndexCtrl = function($scope) {
};

IndexCtrl.$inject = ['$scope'];

angular.module("ShowApp")
       .controller('IndexCtrl', IndexCtrl);
}());

