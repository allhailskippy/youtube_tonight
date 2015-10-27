//= require_self
//= require_tree ./directives
//= require_tree ./resources
//= require_tree ./services

/**
 * @ngdoc module
 * @name shared
 * @module shared
 *
 * @description
 * An angularjs module that contains shareable resources
 */

(function() {
  'use strict';

  angular.module('shared', [
    'ngResource', 'ng-rails-csrf'
  ]);
}());
