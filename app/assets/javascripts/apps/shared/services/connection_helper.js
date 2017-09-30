/**
 * @ngdoc service
 * @name ConnectionHelper
 * @module shared
 *
 * @description
 * Handles connecting to the websocket dispatcher
 * Attempts to reduce the number of connections by
 * re-using them
 *
 * ### Usage
 * <video-preview video="video"></video-preview>
 */
(function() {
'use strict';

var ConnectionHelper = function(
  ApplicationConstants, ActionCableChannel, ActionCableSocketWrangler
) {
  var self = this;

  self.channel = null;
  self.playerIds = {};

  self.wrangler = function() {
    return ActionCableSocketWrangler;
  };

  self.newConsumer = function(channelName, data) {
    return new ActionCableChannel(channelName, data)
  };

  // Can have many players, but only one per base, per page
  self.getPlayerId = function(base) {
    self.playerIds[base] = self.playerIds[base] ||
      base + '-' + Math.floor(Math.random() * 1000000);
    return self.playerIds[base];
  }
};

ConnectionHelper.$inject = [
  'ApplicationConstants', 'ActionCableChannel', 'ActionCableSocketWrangler'
];

angular.module('shared')
       .service('ConnectionHelper', ConnectionHelper);
}());
