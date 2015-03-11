
/**
 * @ngdoc object
 * @name fir.analytics.analyticsInterceptorProvider
 * @description
 * 包含analyticsInterceptor相关设置
 */

(function() {
  angular.module('fir.analytics').provider("analyticsInterceptor", [
    function() {
      var collectParamsToString, that;
      that = this;

      /**
       * @ngdoc property
       * @name isReplace
       * @propertyOf fir.analytics.analyticsInterceptorProvider
       * @description - boolean - 用于设置是否替换，如果设置为true则会调用replaceMethod方法
       */
      this.isReplace = true;

      /**
       * @ngdoc property
       * @name collect
       * @type {object}
       * @propertyOf fir.analytics.analyticsInterceptorProvider
       * @description 用于设置收集信息的类型
       * 
       * - {boolean} - params - 设置是否收集请求的参数 默认为false
       * - {method} - method - 设置是否收集method 默认为true
       * - {status} - status - 设置是否收集请求状态 默认为true
       * - {status} - headers - 设置是否收集请求报文头 默认为false
       * - {status} - result - 设置是否收集请求的返回结果 默认为false
       * - {status} - all - 统一设置 默认为false
       */
      this.collect = {
        params: false,
        method: true,
        status: true,
        headers: false,
        result: false,
        all: false
      };

      /**
       * @ngdoc function
       * @name replaceMethod
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * 替换默认错误方法,改方法多用与替换url中得私密信息,默认正则替换如下：
       * url.replace(/token=\w+/,"token=:token").replace(/\w{24}/,":id").replace(/\w{24}/,":id")
       * 
       * 如果需要，可覆盖重写改方法  
       * @param {object} error 错误请求的详细信息,包含以下字段:
       * 
       * - {string} - url - 请求的url
       * - {string} - method - 请求的方法（post、get、update...)
       * - {string} - params - 请求的参数
       * - {number} - status - 错误请求的code
       * @retrun {object} error 字段包含同上
       */
      this.replaceMethod = function(error) {
        var url;
        url = error.url;
        error.url = url.replace(/token=\w+/, "token=:token").replace(/\w{24}/, ":id").replace(/\w{24}/, ":id");
        return error;
      };

      /**
       * @ngdoc property
       * @name model
       * @propertyOf fir.analytics.analyticsInterceptorProvider
       * @description 用于设置已哪中方式设置，可选值如下
       * 
       * - "exception" : 默认，已异常的方式发送，所有得异常信息都统计在异常说明字段，150字以内
       * - "event": 已事件方式发送，默认exception，对应信息如下：
       * - - 事件类别:"exception_event"(固定)
       * - - 事件操作:异常说明
       * - - 事件标签:异常url
       */
      this.model = 'exception';

      /**
       * 将error对象根据collect设置转成string
       */
      collectParamsToString = function(error) {
        var all, description, name, setting, value, _ref;
        description = "";
        all = that.collect.all;
        _ref = that.collect;
        for (name in _ref) {
          setting = _ref[name];
          if (name === 'all') {
            continue;
          }
          if (setting || all) {
            value = error[name];
            if (!value) {
              value = "undefined";
            } else if (angular.isObject(value)) {
              value = JSON.stringify(value);
            }
            description += ("," + name + ":") + value;
          }
        }
        return description;
      };

      /**
       * @ngdoc function
       * @name $sendExceptionWithEvent
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * private 已事件方式发送
       * 
       * 如果需要，可覆盖重写改方法  
       * @param {object} error 错误请求的详细信息
       */
      this.$sendExceptionWithEvent = function(error) {
        var description;
        description = collectParamsToString(error);
        description = description.length > 1 ? description.substr(1) : description;
        return ga('send', 'event', "exception_event", description, error.url);
      };

      /**
       * @ngdoc function
       * @name $sendException
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * private 已异常方式发送
       * 
       * 如果需要，可覆盖重写改方法  
       * @param {object} error 错误请求的详细信息
       */
      this.$sendException = function(error) {
        var description;
        description = "url:" + error.url;
        description += collectParamsToString(error);
        ga('send', 'exception', {
          exDescription: description,
          exFatal: false
        });
        return true;
      };

      /**
       * @ngdoc object
       * @name fir.analytics.analyticsInterceptor
       * @description
       * 错误分析拦截器，请在所有要拦截错误的module中注入
       * url中参数过滤token
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
      this.$get = [
        '$q', function($q) {
          return {
            responseError: function(resq) {
              var error;
              error = {
                url: resq.config.url,
                method: resq.config.method,
                params: resq.config.data,
                status: resq.status,
                headers: resq.config.headers,
                result: resq.data
              };
              if (that.isReplace) {
                error = that.replaceMethod(error);
              }
              switch (that.model) {
                case 'event':
                  that.$sendExceptionWithEvent(error);
                  break;
                default:
                  that.$sendException(error);
              }
              return $q.reject(resq);
            }
          };
        }
      ];
      return this;
    }
  ]);

}).call(this);
