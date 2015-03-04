
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
  var attrEventList, camelCase, eventList, seachEvent;

  eventList = ['click', 'change', 'dblclick', 'keydown', 'keyup', 'keypress', 'submit'];

  camelCase = function() {
    var array, event, pre, _i, _len;
    pre = 'ng';
    array = [];
    for (_i = 0, _len = eventList.length; _i < _len; _i++) {
      event = eventList[_i];
      array.push(event[0].toUpperCase() + event.substr(1));
    }
    return array;
  };

  attrEventList = camelCase();

  seachEvent = function(attr) {
    var ar, ev, i, _i, _len;
    ar = [];
    for (i = _i = 0, _len = attrEventList.length; _i < _len; i = ++_i) {
      ev = attrEventList[i];
      if (attr['ng' + ev]) {
        ar.push(eventList[i]);
      }
    }
    return ar.join(',');
  };

  angular.module('fir.analytics').directive('gaEvent', [
    '$log', '$compile', '$rootScope', function($log, $compile, $rootScope) {
      return {
        restrict: 'A',
        priority: 1,
        require: "?^gaType",
        link: function(scope, elem, attrs, gaController) {
          var attr_events, events, gaElement;
          if (!gaController) {
            $log.log('no ga-type', elem[0]);
            return;
          }
          gaElement = gaController.getGaElement(elem, attrs);
          attr_events = attrs['gaEvent'];
          events = (attrs["gaEvent"] || seachEvent(attrs) || "click").split(",");
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
              timer = setTimeout(function() {
                var action;
                action = e.type.toLowerCase();
                if (gaElement.tag === 'a') {
                  action = 'link';
                }
                ga("send", "event", gaElement.type, action, gaElement.name, 0);
                num = 0;
              }, gaElement.delay);
            });
          });
          scope.$on('$destroy', function() {
            elem.off();
          });
        }
      };
    }
  ]);

}).call(this);
