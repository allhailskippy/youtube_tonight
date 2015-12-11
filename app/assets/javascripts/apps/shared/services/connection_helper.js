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

var ConnectionHelper = function(ApplicationConstants) {
  var self = this;

  self.dispatcher = null;
  self.channel = null;
  self.playerIds = {};
  self.registeredPlayers = {};

  self.getChannel = function(channel_name, dispatcher) {
    dispatcher = dispatcher || self.getDispatcher();
    self.channel = self.channel
      || self.newChannel(channel_name, dispatcher);
    return self.channel;
  };

  self.getDispatcher = function() {
    self.dispatcher = self.dispatcher
      || self.newDispatcher();

    return self.dispatcher;
  };

  // Can have many players, but only one per base, per page
  self.getPlayerId = function(base) {
    self.playerIds[base] = self.playerIds[base] ||
      base + '-' + Math.floor(Math.random() * 1000000);
    return self.playerIds[base];
  }

  self.newChannel = function(channel_name, dispatcher) {
    return dispatcher.subscribe(channel_name);
  };

  self.newDispatcher = function() {
    var dispatcher = new WebSocketRails(ApplicationConstants.WEBSOCKET_URL);
    return dispatcher;
  };

  self.registeredPlayerCheck = function(dispatcher, channel) {
    // Reset players
    self.registeredPlayers = {};

    dispatcher = dispatcher || getDispatcher();
    channel = channel || getChannel('video_player', dispatcher);

    // See who's alive, this will get picked
    // up on the video-show directive
    dispatcher.trigger('video_player.registered_check', {});

    channel.bind('registered', function(message) {
      var count = self.registeredPlayers[message.player_id]  || 0;
      self.registeredPlayers[message.player_id] = count + 1;
    });

    channel.bind('unregistered', function(message) {
      var count = self.registeredPlayers[message.player_id] || 0;

      // Don't let count dip < 0
      if(count > 0) {
        self.registeredPlayers[message.player_id] = count - 1;
      }
    });
  }
};

ConnectionHelper.$inject = ['ApplicationConstants'];

angular.module('shared')
       .service('ConnectionHelper', ConnectionHelper);
}());
