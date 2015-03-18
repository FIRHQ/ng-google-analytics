
/**
 * @ngdoc object
 * @name fir.analytics.analyticsInterceptorProvider
 * @description
 * 包含analyticsInterceptor相关设置
 * 发送统计完整流程 replaceMethod()->exclude检查->beforeSend()->发送，其中如果exclude结果为true停止，beforeSend()为false停止。
 * 注：如果content['Content-Type'] = undefined (multipart/form-data; 即文件模式)是，无法收集到正确地params，请在config对象中增加gaParams参数已确保统计到正确地参数
 *
 */

(function() {
  angular.module('fir.analytics').provider("analyticsInterceptor", [
    function() {
      var collectParamsToString, exclude, isInExclude, order, parseUrl, that;
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
       * - {status|delete} - status - 设置是否收集请求状态 默认为true(已删除，相关信息品在url后方)
       * - {status} - headers - 设置是否收集请求报文头 默认为false(已删除)
       * - {status} - result - 设置是否收集请求的返回结果 默认为false
       * - {status} - all - 统一设置 默认为false
       */
      this.collect = {
        params: false,
        method: true,
        result: false,
        all: false
      };
      order = ["method", "params", "result"];

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
        error.url = url.replace(/token=\w+/gi, "token=:token").replace(/\w{24}/gi, ":id").replace(/\w{24}/, ":id");
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
        var all, description, name, setting, value, _i, _len;
        description = "";
        all = that.collect.all;
        for (_i = 0, _len = order.length; _i < _len; _i++) {
          name = order[_i];
          setting = that.collect[name];
          if (all || setting) {
            value = error[name];
            if (!value) {
              value = "undefined";
            } else if (that.isBlob(value) || that.isFormData(value)) {
              value = value.toString();
            } else if (angular.isObject(value)) {
              value = JSON.stringify(value);
            }
            description += ("," + name + ":") + value;
          }
        }
        return description;
      };

      /**
       * @ngdoc property
       * @name exclude
       * @propertyOf fir.analytics.analyticsInterceptorProvider
       * @description
       * 排除的统计列表，值应该为{url:status} 模式,在执行次过滤之前会先replaceMehtod方法，用于统一某些url
       */
      exclude = {};

      /**
       * @ngdoc function
       * @name addExclude
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * 发送统计前调用，如果返回false、null、undefined将不会发送统计,可在config中覆盖
       * @param {object|array} 此对象应该为以下结构{url : status| [status]}({地址：请求状态或状态数组}) 或为该结构数组
       * @return {this}  链式。返回当前对象
       */
      this.addExclude = function(objs) {
        var name, obj, status, value, vs, _i, _j, _len, _len1;
        if (!angular.isArray(objs) && angular.isObject(objs)) {
          objs = [objs];
        }
        if (angular.isArray(objs)) {
          for (_i = 0, _len = objs.length; _i < _len; _i++) {
            obj = objs[_i];
            for (name in obj) {
              value = obj[name];
              status = exclude[name];
              status = status || [];
              if (angular.isNumber(value)) {
                status.push(value);
              } else if (angular.isString(value)) {
                value = parseInt(value);
                if (value === NaN) {
                  continue;
                }
                status.push(value);
              } else if (angular.isArray(value)) {
                for (_j = 0, _len1 = value.length; _j < _len1; _j++) {
                  vs = value[_j];
                  vs = parseInt(vs);
                  if (vs === NaN) {
                    continue;
                  }
                  status.push(vs);
                }
              } else {
                continue;
              }
              exclude[name] = status;
            }
          }
        }
        return this;
      };

      /**
       * @ngdoc function
       * @name getExclude
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * 获取排除对象，此方法多用于测试，最好不要在server之外使用
       * @return {object}  返回排除统计列表的对象，见exclude属性
       */
      this.getExclude = function() {
        return exclude;
      };

      /**
       * @ngdoc function
       * @name $clearExclude
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * 私有方法，用于重置exclude，此方法用于测试
       * @return {object}  返回排除统计列表的对象，见exclude属性
       */
      this.$clearExclude = function() {
        return exclude = {};
      };
      isInExclude = function(error) {
        var ss, status, _i, _len;
        status = exclude[error.url];
        if (!status) {
          return false;
        }
        for (_i = 0, _len = status.length; _i < _len; _i++) {
          ss = status[_i];
          if (ss === parseInt(error.status)) {
            return true;
          }
        }
        return false;
      };

      /**
       * @ngdoc function
       * @name beforeSend
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * 发送统计前调用，如果返回false、null、undefined将不会发送统计,可在config中覆盖
       * @param {object} error 错误请求的详细信息
       * @return {boolean} 如果为true则发送统计，false则取消发送此次统计
       */
      this.beforeSend = function(error) {
        return true;
      };
      parseUrl = function(error) {
        var match, param, paramStr, pr, str, url, _i, _len;
        url = error.url;
        param = error.params || {};
        pr = /(\w+)=([^&^#]*)/g;
        paramStr = url.match(pr);
        error.url = url.replace(pr, "$1=:$1");
        if (!paramStr) {
          return;
        }
        for (_i = 0, _len = paramStr.length; _i < _len; _i++) {
          str = paramStr[_i];
          match = str.split("=");
          match[1] = match[1] === '' ? null : match[1];
          param[match[0]] = match[1];
        }
        return error.params = param;
      };

      /**
       * @ngdoc property
       * @name hostDomain
       * @propertyOf fir.analytics.analyticsInterceptorProvider
       * @description 
       * 用于设置当前页面所处得domain域，关联isHostRequest、isOtherRequest方法的判定结果
       */
      this.hostDomain = window.location.host;

      /**
       * @ngdoc function 
       * @name isHostRequest
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * 用于判断当前url是否与locatoin.host是否同一个
       */
      this.isHostRequest = function(url) {
        var hostReg;
        if (!/^http/.test(url)) {
          return true;
        }
        hostReg = new RegExp("://[\\w+\\.]*" + this.hostDomain + "/");
        return hostReg.test(url);
      };

      /**
       * @ngdoc function 
       * @name isOtherRequest
       * @methodOf fir.analytics.analyticsInterceptorProvider
       * @description
       * 用于判断当前url是否与locatoin.host是否不是同一个
       */
      this.isOtherRequest = function(url) {
        return !this.isHostRequest(url);
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
        return ga('send', 'event', "exception_event", description, error.url + " | " + error.status);
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
        description = "" + error.url + " | " + error.status;
        description += collectParamsToString(error);
        return ga('send', 'exception', {
          exDescription: description,
          exFatal: false
        });
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
      this.isFormData = function(obj) {
        if (!obj) {
          return false;
        }
        return obj.constructor.name === 'FormData';
      };
      this.isBlob = function(obj) {
        if (!obj) {
          return false;
        }
        return obj.constructor.name === 'Blob';
      };
      this.$get = [
        '$q', function($q) {
          return {
            responseError: function(resq) {
              var error, r;
              error = {
                url: resq.config.url,
                method: resq.config.method,
                params: resq.config.data || {},
                status: resq.status,
                headers: resq.config.headers,
                result: resq.data
              };
              r = false;
              parseUrl(error);
              if (that.isReplace) {
                that.replaceMethod(error);
              }
              if (!isInExclude(error) && that.beforeSend(error)) {
                if (that.isFormData(error.params)) {
                  error.params = resq.config.gaParams;
                }
                switch (that.model) {
                  case 'event':
                    that.$sendExceptionWithEvent(error);
                    break;
                  default:
                    that.$sendException(error);
                }
                r = true;
                resq.collectError = error;
              }
              resq.isCollect = r;
              return $q.reject(resq);
            }
          };
        }
      ];
      return this;
    }
  ]);

}).call(this);
