
(function(){
'use strict';

var VideoApp = function(ApplicationConstants) {
  var self = this;

  self.dispatcher = null;
  self.channel = null;

  self.getDispatcher = function() {
    self.dispatcher = self.dispatcher || new WebSocketRails(ApplicationConstants.WEBSOCKET_URL);
    return self.dispatcher;
  };

  self.getChannel = function(channel_name) {
    self.channel = self.channel || self.getDispatcher().subscribe(channel_name);
    return self.channel;
  };
};

VideoApp.$inject = ['ApplicationConstants'];

angular.module('VideoApp')
       .service('VideoApp', VideoApp);
}());
