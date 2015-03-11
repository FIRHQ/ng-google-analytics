
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


/**
 *@ngdoc object
 *@name fir.analytics.gaType.GaController
 *@property {string} type ga类型
 *@description
 *ga-type directive controller
 */


/**
 * @ngdoc directive
 * @name fir.analytics.directive:gaType
 * @restrict A
 * @description
 * 统计指令公用的父类，用于解析name、type、delay、only等所有统计用到的公用参数，推荐加上ga
 * 
 * {@link fir.analytics.gaType.GaController controller方法} 

 * @priority 10
 * @example
 * <pre><any ga ga-type='example'/></pre>
 * @param {string} ga-type 对应google analytics Category参数(分类)
 * @param {string|option} ga-name 对应google analytics Label参数，用于唯一标识element对象，如果ga-type值为空，将以.截取gaName的值，第一段位type，而后为name
 * @param {number|options} ga-delay 提交延迟，在该值内，发生的连续相同事件将被忽略
 * @param {boolean|options} ga-only ga-type/ga-name的值是否唯一，默认为true
 */

(function() {
  angular.module('fir.analytics').directive('gaType', [
    '$log', function($log) {
      return {
        restrict: 'A',
        priority: 10,
        controller: [
          '$scope', '$element', '$attrs', function(scope, elem, attrs) {
            var getGaProperty, that, type;
            that = this;
            this.type = type = attrs["gaType"];
            this.gaArray = {};

            /**
             * private 
             * 用与解析element和attr构造出基础ga对象
             */
            getGaProperty = function(element, attr) {
              var delay, gaElement, name, only, tag;
              if (element[0].ga) {
                return element[0].ga;
              }
              tag = element[0].tagName.toLowerCase();
              name = attr["gaName"] || attr["id"] || attr["name"];
              delay = attr["gaDelay"] || 150;
              only = attr["gaOnly"] === '0' || attr["gaOnly"] === 'false' ? false : true;
              if (!name) {
                
                return;
              }
              if (!type) {
                
                return;
              }
              gaElement = {
                tag: tag,
                name: name,
                type: type,
                delay: delay,
                only: only
              };
              if (that.gaArray[name] && only) {
                
                return;
              }
              that.gaArray[name] = true;
              element[0].ga = gaElement;
              return gaElement;
            };

            /**
             * @ngdoc function
             * @name fir.analytics.gaType.GaController#initGaElement
             * @methodOf fir.analytics.gaType.GaController
             * @description 
             * 用于获取ga元素对象
             */
            this.getGaElement = function(element, attr) {
              return getGaProperty(element, attr);
            };
            return this;
          }
        ]
      };
    }
  ]);

}).call(this);


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
                that.replaceMethod(error);
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
