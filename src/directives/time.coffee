###*
# @ngdoc object
# @name fir.analytics.timeAnalytics
# @description
# 用于统计时间
###
#统计时间service
angular.module('fir.analytics').factory('timeAnalytics',[()->
  timeAnalytics = (@category="",@name="",@remark="")->
    @start=()->
      @startTime = new Date()
    @end=()->
      @endTime = new Date()
      timeLine = @endTime - @startTime
      console.log 'timeLine',timeLine
      ga('send','timing',@category,@name,timeLine,@remark)
      return timeLine
    @destroy = ()->
      @startTime = 0
      @endTime = 0 
      return ;
    return @
  return {
    ###*
    # @ngdoc function
    # @name fir.analytics.timeAnalytics#create
    # @methodOf fir.analytics.timeAnalytics
    # @param {string} category google analytics的category
    # @param {string} name google analytics的var
    # @param {string|options} remark timingLabel
    # @description
    # 用于返回计时对象
    # @returns {object}
    #   - start() function 开始计时
    #   - end() function 结束计时，并提交统计的时间
    #   - destroy() function 销毁，不提交统计
    ###
    create:(category,name,remark)->
      #name,subname is required
      return new timeAnalytics(category,name,remark)
  }
])
###*
# @ngdoc directive
# @name fir.analytics.directive:ga-timing
# @description
# 统计时间，不建议使用
# @requires ga
# @restrict A
# @param {boolean|number} ga-timing 监听参数,值为进度条的值
# @param {number} max 最大进度，默认100
# @param {string} ga-timing-remark 对应google analytics label
# @param {string} ga-timing-status 监听参数，true|'1'为开始
###
angular.module('fir.analytics').directive 'gaTiming', ['timeAnalytics',(timeAnalytics)->
  restrict: 'A'
  require:"ga"
  link: (scope, elem, attrs,gaController)->
    gaElement = gaController.getGaElement()
    watch = attrs["gaTiming"] || attrs["ngModel"]
    remark = attrs["gaTimingRemark"]
    watchStart = attrs["gaTimingStatus"]
    if !watch or !watchStart
      throw new Error 'no watch value in ga-timing'
      return 
    timeServer = timeAnalytics.create(gaElement.type,gaElement.name,remark)
    start = false 
    watchProgress = null

    #监听开始变量的变化
    scope.$watch(watchStart,(n,o)->
      #开始计时后停止计时,相当于取消操作
      console.log 'watch start'
      if start and (!n or n is '0' or  n is 0)
        timeServer.destroy()
        start = false
        watchProgress()
        watchProgress = null
      #开始计时
      else if !start and ( n is true or n is '1' or n is 1)
        #开始计时时，获取最大的progress size
        maxSize = parseInt(attrs["max"] || 100)
        console.log 'maxSize',maxSize
        timeServer.start()
        start = true
        #watch进度条变化
        watchProgress = scope.$watch(watch,(n)->
          #达到最大值,初始化参数
          console.log 'size change',n
          if parseInt(n) >= maxSize
            timeServer.end()
            start = false
            watchProgress()
            watchProgress = null
          return ;
        )
      return ;
    )
    return ;
]