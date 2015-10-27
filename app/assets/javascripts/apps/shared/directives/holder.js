/**
 * Fix to allow holder.js to work within a template
 * https://github.com/joshvillbrandt/ng-holder
 */
(function(window, angular, undefined) {
'use strict';

angular.module('shared')
       .directive('holder', [
  function() {
    return {
      link: function(scope, element, attrs) {
        if(attrs.holder)
          attrs.$set('data-src', attrs.holder);
        Holder.run({images:element[0]});
      }
    };
  }]);
})(window, window.angular);
