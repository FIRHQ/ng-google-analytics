
/**
 * @ngdoc overview
 * @name fir.analytics
 * @description
 * # fir.analytics模块
 * 包含统计分析的指令、服务,(统计对象window.ga)
 */

(function() {
  var analytics;

  analytics = angular.module("fir.analytics", ["ng"]);

  analytics.run([
    '$rootScope', '$log', function($rootScope, $log) {
      if (!window.ga) {
        window.ga = function() {};
      }
      $rootScope.$on('authenticated', function(evt, param) {
        var user;
        user = param.user;
        return ga('set', '&uid', user.id);
      });
      $rootScope.$on('$stateChangeSuccess', function(evt, toState) {
        var page, title;
        title = document.title;
        page = toState.name || window.location.pathname;
        $log.log('pageview', page, 'title', title);
        ga('send', 'pageview', {
          title: title,
          page: page,
          location: page
        });
        ga('set', 'location', '');
        return setTimeout(function() {
          var btn, buttons, select, selects, _i, _j, _len, _len1;
          selects = ["input[type='button']", "button", "a"];
          for (_i = 0, _len = selects.length; _i < _len; _i++) {
            select = selects[_i];
            buttons = $(select);
            for (_j = 0, _len1 = buttons.length; _j < _len1; _j++) {
              btn = buttons[_j];
              if (!btn.attributes.ga && (select !== 'a' || !(!btn.attributes.href && !btn.attributes["ng-href"] && !btn.attributes["ng-click"]))) {

              }
            }
          }
        }, 1000);
      });
      return $rootScope.$on('cancellation', function(evt) {
        return ga('set', '&uid', null);
      });
    }
  ]);

}).call(this);
