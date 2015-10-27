(function(){
'use strict';

var Show = function(ShowApi) {
  var self = this;

  self.attributes = [
    'air_date',
    'id',
    'title'
  ];

  self.build = function(show) {
    // Delete show
    show.destroy = function() {
      return ShowApi.delete({id: show.id}).$promise;
    };

    // Decides if model is a new record or not
    show.isNewRecord = function() {
      return !show.id;
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

    // Shows text used on the button for saving a show
    show.saveButtonStr = function() {
      return show.isNewRecord() ? 'Create New Show' : 'Update Show';
    };
    return show;
  };

  /**
   * Setup
   */
  // Sets a blank show by default
  self.currentShow = self.build({});

  /**
   * Class methods
   */
  self.clearCurrentShow = function() {
    self.currentShow = self.build({});
  };

  self.find = function(id) {
    return ShowApi.get({id: id}).$promise;
  };

  self.query = function(params) {
    return ShowApi.query(params).$promise;
  };

  // Set state back to base state
  self.resetCurrentShow = function() {
    self.currentShow = self.build({});
  };

  // Set a blank show as the default current show
  self.setCurrentShow = function(show) {
    self.currentShow = show;
    return self.currentShow;
  };
};

Show.$inject = ['ShowApi'];

angular.module('shared')
       .service('Show', Show);
}());
