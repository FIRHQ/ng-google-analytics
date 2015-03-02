
/**
 * @ngdoc object
 * @name fir.analytics.analyticsInterceptor
 * @description
 * 错误分析拦截器，请在所有要拦截错误的module中注入
 * <pre>
 *   <script>
 *   m = angular.module('someModule',['ng'])
 *   m.config('$httpProvider',($httpProvider)->
 *     $httpProvider.interceptors.push "analyticsInterceptor"
 *   )
 *   </script>
 * </pre>
 * @requires $q
 */

(function() {
  analytics.factory("analyticsInterceptor", [
    '$q', function($q) {
      return {
        responseError: function(resq) {
          var url;
          url = resq.config.url;
          url = url.replace(/token=\w+/, "token=:token").replace(/\w{24}/, ":id").replace(/\w{24}/, ":id");
          ga('send', 'exception', {
            exDescription: url + ' status:' + resq.status,
            exFatal: false,
            name: "Fir.model",
            version: "3.0",
            url: url,
            method: resq.config.method,
            requestParam: resq.config.params
          });
          return $q.reject(resq);
        }
      };
    }
  ]);

}).call(this);
