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
  self.registeredPlayers = {};

  self.broadcastReady = function(broadcastId) {
    return self.registeredPlayers[broadcastId] > 0;
  };

  self.newConsumer = function(channelName, streamId) {
    return new ActionCableChannel(channelName, streamId)
  };

  // Can have many players, but only one per base, per page
  self.getPlayerId = function(base) {
    self.playerIds[base] = self.playerIds[base] ||
      base + '-' + Math.floor(Math.random() * 1000000);
    return self.playerIds[base];
  }

  self.registeredPlayerCheck = function($scope) {
    // Reset players
    self.registeredPlayers = {};

    var consumer = self.newConsumer('VideoPlayerChannel', 'video_player');
    consumer.subscribe(function(response) {
      var message = response.message;
      switch(response.action) {
        case 'registered':
          var count = self.registeredPlayers[message.player_id]  || 0;
          self.registeredPlayers[message.player_id] = count + 1;
          break;
        case 'unregistered':
          var count = self.registeredPlayers[message.player_id] || 0;
          self.registeredPlayers[message.player_id] = (count > 0 ) ? count - 1 : 0;
          break;
      }
    });

    $scope.$watch(function() {
      return ActionCableSocketWrangler.connected
    }, function(newVal, oldVal) {
      if(newVal == true) {
        consumer.send({}, 'registered_check');
      }
    });
  }
};

ConnectionHelper.$inject = [
  'ApplicationConstants', 'ActionCableChannel', 'ActionCableSocketWrangler'
];

angular.module('shared')
       .service('ConnectionHelper', ConnectionHelper);
}());
