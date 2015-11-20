(function(){
'use strict';

var CurrentUser = function(
  $filter,
  CurrentUserApi, User
  ) {
  var self = this;

  self.attributes = [
    'id',
    'change_roles',
    'name',
    'email',
    'requires_auth',
    'role_titles'
  ];

  self.build = function(user) {
    return User.build(user);
  };

  /**
   * Class methods
   */
  self.find = function() {
    return CurrentUserApi.query().$promise;
  };
};

CurrentUser.$inject = [
  '$filter',
  'CurrentUserApi', 'User'
];

angular.module('shared')
       .service('CurrentUser', CurrentUser);
}());
