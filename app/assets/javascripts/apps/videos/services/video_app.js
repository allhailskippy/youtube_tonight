
(function(){
'use strict';

var VideoApp = function(ApplicationConstants) {
  var self = this;

  self.dispatcher = null;
  self.channel = null;
  self.playerIds = {};

  self.getDispatcher = function() {
    self.dispatcher = self.dispatcher
      || new WebSocketRails(ApplicationConstants.WEBSOCKET_URL);
    return self.dispatcher;
  };

  self.getChannel = function(channel_name) {
    self.channel = self.channel
      || self.getDispatcher().subscribe(channel_name);
    return self.channel;
  };

  // Can have many players, but only one per base, per page
  self.getPlayerId = function(base) {
    self.playerIds[base] = self.playerIds[base] ||
      base + '-' + Math.floor(Math.random() * 1000000);
    return self.playerIds[base];
  }
};

VideoApp.$inject = ['ApplicationConstants'];

angular.module('VideoApp')
       .service('VideoApp', VideoApp);
}());
