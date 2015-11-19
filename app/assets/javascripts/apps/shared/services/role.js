(function(){
'use strict';

var Role = function(RoleApi) {
  var self = this;

  self.attributes = [
    'id',
    'title'
  ];

  self.build = function(role) {
    // Save model to server side
    role.save = function() {
      var $promise;
      var saveData = {};

      //Restrict to only valid attributes
      angular.forEach(self.attributes, function(attr) {
        saveData[attr] = role[attr];
      });

      var params = {
        role: saveData
      };

      // Different calls for new vs existing
      if(role.id) {
        $promise = RoleApi.update({ id: role.id }, params).$promise;
      } else {
        $promise = RoleApi.save(params).$promise;
      }
      return $promise;
    };
    return role;
  };

  /**
   * Class methods
   */
  self.query = function(params) {
    return RoleApi.query(params).$promise;
  };
};

Role.$inject = ['RoleApi'];

angular.module('shared')
       .service('Role', Role);
}());
