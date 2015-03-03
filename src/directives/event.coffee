###*
# @ngdoc directive
# @name fir.analytics.directive:ga-event
# @restrict A
# @requires ^gaType
# @priority 1
# @description
# 用于统计事件请求
# @param {string} ga-event 事件名，如果是多事件，以','分隔 ，默认为'click'

###
eventList = ['click','change','dblclick','keydown','keyup', 'keypress', 'submit']
  
camelCase = ()->
  pre = 'ng'
  array = []
  for event in eventList
    array.push event[0].toUpperCase() + event.substr(1)
  return array

attrEventList = camelCase()

seachEvent = (attr)->
  ar = []
  for ev,i in attrEventList
    if attr['ng' + ev] 
      ar.push(eventList[i])
  return ar.join(',')

angular.module('fir.analytics').directive 'gaEvent', ['$log','$compile','$rootScope',($log,$compile,$rootScope)->
  restrict: 'A'
  priority:1
  require:"?^gaType" #如果不存在不影响程序的其他正常功能
  link: (scope, elem, attrs,gaController)->
    if !gaController
      $log.log 'no ga-type',elem[0]
      return ;
    gaElement = gaController.getGaElement(elem,attrs)

    attr_events = attrs['gaEvent']
    events = (attrs["gaEvent"] || seachEvent(attrs) || "click").split(",")
    gaElement.events = []

    angular.forEach(events,(evt,k)->
      num = 0
      timer = null
      gaElement.events.push evt
      elem.on(evt,(e)->
        num++
        if timer 
          clearTimeout(timer)
          timer = null
        #延迟提交
        timer = setTimeout(()->
          #忽略快速的多次点击
          action = e.type.toLowerCase()
          if gaElement.tag is 'a'
            action = 'link'
          # $log.log 'ga directive:',gaElement.type,action,gaElement.name,num
          ga("send","event",gaElement.type,action,gaElement.name,0)
          num = 0
          return ;
        ,gaElement.delay)
        return ;
      )
      return ;
    )
    scope.$on('$destroy',()->
      elem.off()
      return;
    )
    return ;
]
