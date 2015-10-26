(function(){
'use strict';

var Notice = function() {
  var self = this;

  // Default values
  self.defaults = function() {
    return {
      alerts: null,
      errors: null,
      successes: null,
      warnings: null
    };
  };

  // Current state of notices
  self.notices = {
    alerts: null,
    errors: null,
    successes: null,
    warnings: null
  };

  // Resets notices to default values
  self.reset = function() {
    self.notices = self.defaults();
  };

  // Handle error response from server side
  // common behaviour
  self.handleErrors = function(response) {
    var errors = null;
    if(response.data && response.data.full_errors) {
      errors = response.data.full_errors;
    } else if(response.data && response.data.errors) {
      errors = response.data.errors;
    } else if(response.status == 500) {
      errors = ['Internal Server Error'];
    } else {
      errors = ['An unknown error occurred'];
    }
    self.setErrors(errors);
  };

  // Wrapper function for setting alerts
  self.setAlerts = function(alerts, preserveState) {
    self.setNotice('alerts', alerts, preserveState);
  };

  // Wrapper function for setting errors
  self.setErrors = function(errors, preserveState) {
    self.setNotice('errors', errors, preserveState);
  };

  // Wrapper function for setting successes
  self.setSuccesses = function(successes, preserveState) {
    self.setNotice('successes', successes, preserveState);
  };

  // Wrapper function for setting errors
  self.setWarnings = function(warnings, preserveState) {
    self.setNotice('warnings', warnings, preserveState);
  };

  // Method for setting different type of notices
  self.setNotice = function(type, values, preserveState) {
    preserveState = preserveState || false;

    if(!preserveState) { self.reset(); }

    // Allow for passing in a string
    if(typeof values == 'string') {
      values = [values];
    }

    // Set errors
    self.notices[type] = values;
  }
};

angular.module('shared')
       .service('Notice', Notice);
}());

