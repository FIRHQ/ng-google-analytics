#基类
###*
# @ngdoc directive
# @name fir.analytics.directive:gaType
# @restrict A
# @description
# 统计指令公用的父类，用于解析name、type、delay、only等所有统计用到的公用参数，推荐加上ga
# @priority 10
# @example
# <pre><any ga ga-type='example'/></pre>
# @param {string} ga-type 对应google analytics Category参数(分类)
# @param {string} ga-name 对应google analytics Label参数，用于唯一标识element对象，如果ga-type值为空，将以.截取gaName的值，第一段位type，而后为name
# @param {number|options} ga-delay 提交延迟，在该值内，发生的连续相同事件将被忽略
# @param {boolean|options} ga-only ga-type/ga-name的值是否唯一，默认为true 
###
angular.module('fir.analytics').directive 'gaType', [()->
  restrict: 'A'
  priority:10
  # scope:{}
  controller:['$scope','$element','$attrs',(scope,elem,attrs)->
    ###*
    ###
    that = @
    @type = type = attrs["gaType"]
    @gaArray = {}
    # check.regist(gaElement,only)
    # scope.$on("$destroy",()->
    #   check.unRegist(gaElement)
    # )
    ###*
    ###
    # udf()
    getGaProperty = (element,attr)->
      tag = element[0].tagName.toLowerCase()
      name = attr["gaName"] || attr["id"] || attr["name"]
      delay = attr["gaDelay"] || 150 #ms 
      only = if attr["gaOnly"] is '0' or attr["gaOnly"] is 'false' then false else true

      if !name
        $log.error 'ga analytics has no name while return ',element
        throw new Error("no name in google analytics")
      #name 的第一位不能为.
      # if !type and (tindex = name.indexOf('.')) > 0 
      #   type = name.substring(0,tindex)
      #   name = name.substring(tindex + 1,name.length)
      # type = type || attrs['type']
      if !type 
        $log.error 'ga analytics has no type, the name is ', name
        throw new Error("no type in google analytics")
      #ga对象
      gaElement = {
        tag
        name
        type
        delay
        only
      }
      if that.gaArray[name] && only
        $log.error 'some name ',name,' type ',type,' element ',element
        throw new Error("some name with other element")
      that.gaArray[name] = gaElement

      return gaElement
    
    ###*
    # @ngdoc function
    # @name fir.analytics.gaType#initGaElement
    # @methodOf fir.analytics.directive:gaType
    # @description 
    # 用于获取ga元素对象
    ###
    @initGaElement = (element,attr)->
      return getGaProperty(element,attr)
    ###*
    ###
    @getGaElement = (name)->
      return @gaArray[name]
    scope.controller = @
    return @
  ] 
]
