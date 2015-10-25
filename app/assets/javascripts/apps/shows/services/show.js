(function(){
'use strict';

var Show = function(ShowApi) {
  var self = this;

  self.attributes = [
    'title',
    'link',
    'start_time',
    'end_time'
  ];

  self.build = function(show) {
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
