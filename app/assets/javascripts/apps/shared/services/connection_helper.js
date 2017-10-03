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

  self.registeredPlayers = {};

  self.monitorBroadcasts = function(broadcastId) {
    self.registeredPlayers = {};
    var consumer = self.newConsumer('VideoPlayerChannel', { player_id: 'monitor', broadcast_id: broadcastId });
    consumer.subscribe(function(response) {
      var message = response.message;
      switch(response.action) {
        case 'registered':
          self.registeredPlayers[message.broadcast_id] = self.registeredPlayers[message.broadcast_id] || []
          if(self.registeredPlayers[message.broadcast_id].indexOf(message.player_id) < 0) {
            self.registeredPlayers[message.broadcast_id].push(message.player_id);
          }
          break;
        case 'unregistered':
          var n = self.registeredPlayers[message.broadcast_id].indexOf(message.player_id);
          self.registeredPlayers[message.broadcast_id].splice(n, 1);
          break;
      }
    });
    consumer.onConfirmSubscription(function() {
      consumer.send({
        player_id: 'monitor',
        broadcast_id: broadcastId
      }, 'registered_check');
    });
  };

  self.broadcastReady = function(broadcastId) {
    self.registeredPlayers[broadcastId] = self.registeredPlayers[broadcastId] || []
    return self.registeredPlayers[broadcastId].length > 0;
  };
};

ConnectionHelper.$inject = [
  'ApplicationConstants', 'ActionCableChannel', 'ActionCableSocketWrangler'
];

angular.module('shared')
       .service('ConnectionHelper', ConnectionHelper);
}());
