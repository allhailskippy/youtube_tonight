(function(){
'use strict';

var User = function(
  $filter,
  UserApi, Role
  ) {
  var self = this;

  self.attributes = [
    'id',
    'name',
    'email',
    'requires_auth',
    'role_titles'
  ];

  self.build = function(user) {
    // Wrapper method for authorizing a user
    user.authorize = function() {
      user.requires_auth = false;
      user.role_titles = ['host']; // Default role
      return user.save();
    };

    // Wrapper method for de-authorizing a user
    user.deAuthorize = function() {
      user.requires_auth = true;
      return user.save();
    };

    // Delete user
    user.destroy = function() {
      return UserApi.delete({id: user.id}).$promise;
    };

    user.roleTitleStr = function() {
      var roleStr = [];
      angular.forEach(user.role_titles, function(role) {
        this.push(role.charAt(0).toUpperCase() + role.substr(1));
      }, roleStr);
      return roleStr.join(", ");
    }

    // Save model to server side
    user.save = function() {
      var $promise;
      var saveData = {};

      //Restrict to only valid attributes
      angular.forEach(self.attributes, function(attr) {
        saveData[attr] = user[attr];
      });

      var params = {
        user: saveData
      };

      // Different calls for new vs existing
      if(user.id) {
        $promise = UserApi.update({ id: user.id }, params).$promise;
      } else {
        $promise = UserApi.save(params).$promise;
      }
      return $promise;
    };

    return user;
  };

  /**
   * Class methods
   */
  self.find = function(id) {
    return UserApi.get({id: id}).$promise;
  };

  self.query = function(params) {
    return UserApi.query(params).$promise;
  };
};

User.$inject = [
  '$filter',
  'UserApi', 'Role'
];

angular.module('shared')
       .service('User', User);
}());
