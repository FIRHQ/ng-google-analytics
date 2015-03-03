
###*
#@ngdoc object
#@name fir.analytics.gaType.GaController
#@property {string} type ga类型
#@description
#ga-type directive controller
###

###*
# @ngdoc directive
# @name fir.analytics.directive:gaType
# @restrict A
# @description
# 统计指令公用的父类，用于解析name、type、delay、only等所有统计用到的公用参数，推荐加上ga
# 
# {@link fir.analytics.gaType.GaController controller方法} 

# @priority 10
# @example
# <pre><any ga ga-type='example'/></pre>
# @param {string} ga-type 对应google analytics Category参数(分类)
# @param {string|option} ga-name 对应google analytics Label参数，用于唯一标识element对象，如果ga-type值为空，将以.截取gaName的值，第一段位type，而后为name
# @param {number|options} ga-delay 提交延迟，在该值内，发生的连续相同事件将被忽略
# @param {boolean|options} ga-only ga-type/ga-name的值是否唯一，默认为true 
###
angular.module('fir.analytics').directive 'gaType', ['$log',($log)->
  restrict: 'A'
  priority:10
  # scope:{}
  controller:['$scope','$element','$attrs',(scope,elem,attrs)->
    
    that = @
    @type = type = attrs["gaType"]
    @gaArray = {}
    ###*
    # private 
    # 用与解析element和attr构造出基础ga对象
    ###
    getGaProperty = (element,attr)->
      return element[0].ga if element[0].ga

      tag = element[0].tagName.toLowerCase()
      name = attr["gaName"] || attr["id"] || attr["name"]
      delay = attr["gaDelay"] || 150 #ms 
      only = if attr["gaOnly"] is '0' or attr["gaOnly"] is 'false' then false else true

      if !name
        $log.error 'ga analytics has no name while return ',element
        return ;

      if !type 
        $log.error 'ga analytics has no type, the name is ', name,element
        return ;

      #构造ga对象
      gaElement = {
        tag
        name
        type
        delay
        only
      }
      # 之前已经判断过是否解析过，在此处若有同名的，则一定不是同一个element，
      if that.gaArray[name] and only
        $log.error 'some name ',name,' type ',type,' element ',element
        return ;
      that.gaArray[name] = true 

      element[0].ga = gaElement
      return gaElement
    
    ###*
    # @ngdoc function
    # @name fir.analytics.gaType.GaController#initGaElement
    # @methodOf fir.analytics.gaType.GaController
    # @description 
    # 用于获取ga元素对象
    ###
    @getGaElement = (element,attr)->
      return getGaProperty(element,attr)
    return @
  ] 
]
