
/**
 * @ngdoc directive
 * @name fir.analytics.directive:gaType
 * @restrict A
 * @description
 * 统计指令公用的父类，用于解析name、type、delay、only等所有统计用到的公用参数，推荐加上ga
 * @priority 10
 * @example
 * <pre><any ga ga-type='example'/></pre>
 * @param {string} ga-type 对应google analytics Category参数(分类)
 * @param {string} ga-name 对应google analytics Label参数，用于唯一标识element对象，如果ga-type值为空，将以.截取gaName的值，第一段位type，而后为name
 * @param {number|options} ga-delay 提交延迟，在该值内，发生的连续相同事件将被忽略
 * @param {boolean|options} ga-only ga-type/ga-name的值是否唯一，默认为true
 */

(function() {
  angular.module('fir.analytics').directive('gaType', [
    function() {
      return {
        restrict: 'A',
        priority: 10,
        controller: [
          '$scope', '$element', '$attrs', function(scope, elem, attrs) {

            /**
             */
            var getGaProperty, that, type;
            that = this;
            this.type = type = attrs["gaType"];
            this.gaArray = {};

            /**
             */
            getGaProperty = function(element, attr) {
              var delay, gaElement, name, only, tag;
              tag = element[0].tagName.toLowerCase();
              name = attr["gaName"] || attr["id"] || attr["name"];
              delay = attr["gaDelay"] || 150;
              only = attr["gaOnly"] === '0' || attr["gaOnly"] === 'false' ? false : true;
              if (!name) {
                $log.error('ga analytics has no name while return ', element);
                throw new Error("no name in google analytics");
              }
              if (!type) {
                $log.error('ga analytics has no type, the name is ', name);
                throw new Error("no type in google analytics");
              }
              gaElement = {
                tag: tag,
                name: name,
                type: type,
                delay: delay,
                only: only
              };
              if (that.gaArray[name] && only) {
                $log.error('some name ', name, ' type ', type, ' element ', element);
                throw new Error("some name with other element");
              }
              that.gaArray[name] = gaElement;
              return gaElement;
            };

            /**
             * @ngdoc function
             * @name fir.analytics.gaType#initGaElement
             * @methodOf fir.analytics.directive:gaType
             * @description 
             * 用于获取ga元素对象
             */
            this.initGaElement = function(element, attr) {
              return getGaProperty(element, attr);
            };

            /**
             */
            this.getGaElement = function(name) {
              return this.gaArray[name];
            };
            scope.controller = this;
            return this;
          }
        ]
      };
    }
  ]);

}).call(this);
