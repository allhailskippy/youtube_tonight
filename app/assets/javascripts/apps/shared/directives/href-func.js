
var HrefFunc = function($parse) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      var url = $parse(attrs.hrefFunc)(scope);
      element.attr('href', url);
    }
  }
};
HrefFunc.$inject = ['$parse'];
angular.module('shared')
       .directive('hrefFunc', HrefFunc);
