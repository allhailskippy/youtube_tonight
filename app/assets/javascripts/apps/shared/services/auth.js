/**
 * @ngdoc service
 * @name Auth
 * @module shared
 *
 * @description authentication related features
 */
(function() {
  'use strict';

var Auth = function() {
  this.$get = function() {
    /**
     * Setup
     */
    var self = this;
    this.currentUser;

    /**
     * Class Methods
     */
    this.setCurrentUser = function(user) {
      self.currentUser = user;
    };

    this.getXCSRFToken = function() {
      return self.currentUser.xCSRFToken;
    };

    this.permittedTo = function(permission) {
      if (!self.currentUser) {
        return true;
      }
      var privilege = permission.split('.')[0];
      var attribute = permission.split('.')[1];

      var permitted = false;
      var rules = self.currentUser.authRules;
      if (!rules || !rules[privilege]) {
        return false;
      } else {
        permitted = (rules[privilege].indexOf(attribute) !== -1);
      }
      return permitted;
    };

    return this;
  };
  this.$get.$inject = [];
};

angular.module('shared')
       .provider('Auth', Auth);
})();
