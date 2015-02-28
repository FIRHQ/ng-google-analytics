###*
# @ngdoc directive
# @name fir.analytics.directive:ga-event
# @restrict A
# @requires gaType
# @priority 1
# @description
# 用于统计事件请求
# @param {string} ga-event 事件名，如果是多事件，以','分隔 ，默认为'click'

###
angular.module('fir.analytics').directive 'gaEvent', ['gaCheck',(check)->
  restrict: 'A'
  priority:1
  require:"^gaType"
  link: (scope, elem, attrs,gaController)->
    #input type  || a 
    events = (attrs["gaEvent"] || "click").split(",")
    gaElement = gaController.getGaElement()
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
          console.log 'ga directive:',gaElement.type,action,gaElement.name,num
          ga("send","event",gaElement.type,action,gaElement.name,0)
          num = 0
        ,gaElement.delay)
      )
      return ;
    )
    scope.$on('$destroy',()->
      elem.off()
    )
    return ;
]
