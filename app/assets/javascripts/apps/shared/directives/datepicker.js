/**
 * Angular code for using jquery datepicker
 * http://www.abequar.net/posts/jquery-ui-datepicker-with-angularjs
 */
angular.module('shared')
       .directive('datepicker', function() {
  return {
    restrict: 'A',
    require : 'ngModel',
    link : function (scope, element, attrs, ngModelCtrl) {
      $(function(){
        element.datepicker({
          dateFormat: 'yy-mm-dd',
          onSelect:function (date) {
            scope.$apply(function () {
              ngModelCtrl.$setViewValue(date);
            });
          }
        });
      });
    }
  }
});
