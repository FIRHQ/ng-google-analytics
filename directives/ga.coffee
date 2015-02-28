###*
# @ngdoc directive
# @name fir.analytics.directive:gaType
# @restrict A
# @description
# 统计指令公用的父类，用于解析name、type、delay、only等所有统计用到的公用参数，推荐加上ga
# @priority 10
# @example
# <pre><any ga ga-type='example'/></pre>
# @property {string} type ga的caption分类，一般为页面名称
# @property {Object} gaArray 所有此gaType指令下面的ga指令的集合
# @param {string} ga-type 对应google analytics Category参数(分类)
# @param {string} ga-name 对应google analytics Label参数，用于唯一标识element对象，如果ga-type值为空，将以.截取gaName的值，第一段位type，而后为name
# @param {number|options} ga-delay 提交延迟，在该值内，发生的连续相同事件将被忽略
# @param {boolean|options} ga-only ga-name的值是否唯一，默认为true 
###
angular.module('fir.analytics').directive 'gaType', [()->
  restrict: 'A'
  priority:10
  # scope:{}
  controller:['$scope','$element','$attrs','$injector',(scope,elem,attrs,$injector)->
    ###*
    ###
    that = @
    #解析element属性
    tag = element[0].tagName.toLowerCase()
    name = attr["gaName"] || attr["id"] || attr["name"]
    delay = attr["gaDelay"] || 150 #ms 
    only = if attr["gaOnly"] is '1' or attr["gaOnly"] is 'true' then true else false
    @type = type = attrs["gaType"]

    #校验
    if !name
      console.error 'ga analytics has no name while return ',element
      throw new Error("no name in google analytics")
    if !type 
      console.error 'ga analytics has no type, the name is ', name
      throw new Error("no type in google analytics")
      
    @gaArray = {}
    getGaProperty = (element,attr)->
      #ga对象
      gaElement = {
        tag
        name
        type
        delay
        only
      }
      if that.gaArray[name] && only
        console.error 'some name ',name,' type ',type,' element ',element
        throw new Error("some name with other element")
      that.gaArray[name] = gaElement

      return gaElement
    
    ###*
    # @ngdoc function
    # @name fir.analytics.gaType#initGaElement
    # @methodOf fir.analytics.directive:gaType
    # @params {element} element ga标签元素对象,jquery或jqlite对象
    # @params {attr} attr ga标签元素属性
    # @description 
    # 通过元素，属性，初始化ga对象
    ###
    @initGaElement = (element,attr)->
      return getGaProperty(element,attr)
    ###*
    # @ngdoc function
    # @name fir.analytics.gaType#initGaElement
    # @methodOf fir.analytics.directive:gaType
    # @params {element} element ga标签元素对象,jquery或jqlite对象
    # @params {attr} attr ga标签元素属性
    # @description 
    # 通过元素，属性，初始化ga对象
    ###
    @getGaElement = (name)->
      return @gaArray[name]
    scope.controller = @
    return @
  ] 
]