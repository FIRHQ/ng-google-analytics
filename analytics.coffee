###*
# @ngdoc overview
# @name fir.analytics
# @description
# # fir.analytics模块
# 包含统计分析的指令、服务,(统计对象window.ga)
###
analytics = angular.module "fir.analytics", ["ng"]



#事件响应并统计
analytics.run(['$rootScope','$log',($rootScope,$log)->
  if !window.ga 
    window.ga = ()->
      return ;
  #登录
  $rootScope.$on('authenticated',(evt,param)->
    user = param.user
    ga('set','&uid',user.id)
  )
  #切换视图
  $rootScope.$on('$stateChangeSuccess',(evt, toState)->
    title =  document.title
    page = toState.name|| window.location.pathname
    $log.log 'pageview',page,'title',title
    ga('send', 'pageview',{title,page,location:page})
    ga('set','location','')
    setTimeout(()->
      selects = ["input[type='button']","button","a"]
      for select in selects 
        buttons = $(select)
        for btn in buttons
          if !btn.attributes.ga && ( select isnt 'a' or !(!btn.attributes.href and !btn.attributes["ng-href"] and !btn.attributes["ng-click"])) 
            # console.log btn
            ;
      return ;
    ,1000)
  )
  #注销
  $rootScope.$on('cancellation',(evt)->
    ga('set','&uid',null)
  )
])

#校验
# angular.module('fir.analytics').factory('gaCheck',[()->
#   gaArray = {}
#   count = 0
#   window.gaArray = gaArray

#   @regist = (ga,only = true)->
#     count++
#     window.gaCount = count
#     map = gaArray[ga.type] || {}
#     if map[ga.name] 
#       if only
#         console.error 'the ga directive has same name:',ga.name,'type',ga.type
#       # else 
#         # console.log 'the ga directive has same name,but has ga-only param is false,name:',ga.name
#       return
#     map[ga.name] = ga
#     gaArray[ga.type] = map
#     return
#   @unRegist = (ga)->
#     map =  gaArray[ga.type]
#     if map && map[ga.name]
#       delete map[ga.name]
#       count--
#   return @
# ])
