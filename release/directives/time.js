
/**
 * @ngdoc object
 * @name fir.analytics.timeAnalytics
 * @description
 * 用于统计时间
 */

(function() {
  angular.module('fir.analytics').factory('timeAnalytics', [
    function() {
      var timeAnalytics;
      timeAnalytics = function(category, name, remark) {
        this.category = category != null ? category : "";
        this.name = name != null ? name : "";
        this.remark = remark != null ? remark : "";
        this.start = function() {
          return this.startTime = new Date();
        };
        this.end = function() {
          var timeLine;
          this.endTime = new Date();
          timeLine = this.endTime - this.startTime;
          console.log('timeLine', timeLine);
          ga('send', 'timing', this.category, this.name, timeLine, this.remark);
          return timeLine;
        };
        this.destroy = function() {
          this.startTime = 0;
          this.endTime = 0;
        };
        return this;
      };
      return {

        /**
         * @ngdoc function
         * @name fir.analytics.timeAnalytics#create
         * @methodOf fir.analytics.timeAnalytics
         * @param {string} category google analytics的category
         * @param {string} name google analytics的var
         * @param {string|options} remark timingLabel
         * @description
         * 用于返回计时对象
         * @returns {object}
         *   - start() function 开始计时
         *   - end() function 结束计时，并提交统计的时间
         *   - destroy() function 销毁，不提交统计
         */
        create: function(category, name, remark) {
          return new timeAnalytics(category, name, remark);
        }
      };
    }
  ]);


  /**
   * @ngdoc directive
   * @name fir.analytics.directive:ga-timing
   * @description
   * 统计时间，不建议使用
   * @requires ga
   * @restrict A
   * @param {boolean|number} ga-timing 监听参数,值为进度条的值
   * @param {number} max 最大进度，默认100
   * @param {string} ga-timing-remark 对应google analytics label
   * @param {string} ga-timing-status 监听参数，true|'1'为开始
   */

  angular.module('fir.analytics').directive('gaTiming', [
    'timeAnalytics', function(timeAnalytics) {
      return {
        restrict: 'A',
        require: "ga",
        link: function(scope, elem, attrs, gaController) {
          var gaElement, remark, start, timeServer, watch, watchProgress, watchStart;
          gaElement = gaController.getGaElement();
          watch = attrs["gaTiming"] || attrs["ngModel"];
          remark = attrs["gaTimingRemark"];
          watchStart = attrs["gaTimingStatus"];
          if (!watch || !watchStart) {
            throw new Error('no watch value in ga-timing');
            return;
          }
          timeServer = timeAnalytics.create(gaElement.type, gaElement.name, remark);
          start = false;
          watchProgress = null;
          scope.$watch(watchStart, function(n, o) {
            var maxSize;
            console.log('watch start');
            if (start && (!n || n === '0' || n === 0)) {
              timeServer.destroy();
              start = false;
              watchProgress();
              watchProgress = null;
            } else if (!start && (n === true || n === '1' || n === 1)) {
              maxSize = parseInt(attrs["max"] || 100);
              console.log('maxSize', maxSize);
              timeServer.start();
              start = true;
              watchProgress = scope.$watch(watch, function(n) {
                console.log('size change', n);
                if (parseInt(n) >= maxSize) {
                  timeServer.end();
                  start = false;
                  watchProgress();
                  watchProgress = null;
                }
              });
            }
          });
        }
      };
    }
  ]);

}).call(this);
