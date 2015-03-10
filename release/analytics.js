
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


  /**
   * @ngdoc object
   * @name fir.analytics.analyticsConfig
   * @description
   * 用于设置统计分析的一些变量
   * @property {string} preState 设置统计ui.router.$state.name时所加的前缀，防止可能出现2个application有同样地ui.state
   */

  analytics.provider('analyticsConfig', function() {
    var that;
    that = this;
    this.preState = "";
    this.$get = function() {
      return {
        preState: function(value) {
          if (value) {
            that.preState = value;
          }
          if (that.preState) {
            return that.preState + ".";
          } else {
            return '';
          }
        }
      };
    };
    return this;
  });

  analytics.run([
    '$rootScope', '$log', 'analyticsConfig', function($rootScope, $log, analyticsConfig) {
      console.log;
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
        page = analyticsConfig.preState() + toState.name || window.location.pathname;
        
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
