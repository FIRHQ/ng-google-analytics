
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
