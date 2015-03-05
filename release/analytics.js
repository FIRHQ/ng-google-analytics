
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
        title = $rootScope.title || document.title;
        page = toState.name || window.location.pathname;
        $log.log('pageview', page, 'title', title);
        ga('send', 'pageview', {
          title: title,
          page: page,
          location: page
        });
        return ga('set', 'location', '');
      });
      return $rootScope.$on('cancellation', function(evt) {
        return ga('set', '&uid', null);
      });
    }
  ]);

}).call(this);
