
/**
 * @ngdoc directive
 * @name fir.analytics.directive:ga-event
 * @restrict A
 * @requires ^gaType
 * @priority 1
 * @description
 * 用于统计事件请求
 * @param {string} ga-event 事件名，如果是多事件，以','分隔 ，默认为'click'
 */

(function() {
  angular.module('fir.analytics').directive('gaEvent', [
    '$log', function($log) {
      return {
        restrict: 'A',
        priority: 1,
        require: "?^gaType",
        link: function(scope, elem, attrs, gaController) {
          var events, gaElement;
          if (!gaController) {
            $log.log('no ga-type', elem[0]);
            return;
          }
          events = (attrs["gaEvent"] || "click").split(",");
          gaElement = gaController.initGaElement(elem, attrs);
          gaElement.events = [];
          angular.forEach(events, function(evt, k) {
            var num, timer;
            num = 0;
            timer = null;
            gaElement.events.push(evt);
            elem.on(evt, function(e) {
              num++;
              if (timer) {
                clearTimeout(timer);
                timer = null;
              }
              return timer = setTimeout(function() {
                var action;
                action = e.type.toLowerCase();
                if (gaElement.tag === 'a') {
                  action = 'link';
                }
                ga("send", "event", gaElement.type, action, gaElement.name, 0);
                return num = 0;
              }, gaElement.delay);
            });
          });
          scope.$on('$destroy', function() {
            return elem.off();
          });
        }
      };
    }
  ]);

}).call(this);
