(function(){
'use strict';

var Show = function(ShowApi) {
  var self = this;

  self.attributes = [
    'title',
    'air_date'
  ];

  self.build = function(show) {
    // Decides if model is a new record or not
    show.isNewRecord = function() {
      return !!show.id;
    };

    // Save model to server side
    show.save = function() {
      var $promise;
      var saveData = {};

      //Restrict to only valid attributes
      angular.forEach(self.attributes, function(attr) {
        saveData[attr] = show[attr];
      });

      var params = {
        show: saveData
      };

      // Different calls for new vs existing
      if(show.id) {
        $promise = ShowApi.update({ id: show.id }, params).$promise;
      } else {
        $promise = ShowApi.save(params).$promise;
      }
      return $promise;
    };
    return show;
  };

  self.find = function(id) {
    return ShowApi.get({id: id}).$promise;
  };

  self.query = function(params) {
    return ShowApi.query(params).$promise;
  };
};

Show.$inject = ['ShowApi'];

angular.module('ShowApp')
       .service('Show', Show);
}());
