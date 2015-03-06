###*
# @ngdoc overview
# @name fir.analytics
# @description
# # fir.analytics模块
# 包含统计分析的指令、服务,(统计对象window.ga)
###
analytics = angular.module "fir.analytics", ["ng"]

###*
# @ngdoc object
# @name fir.analytics.analyticsConfig
# @description
# 用于设置统计分析的一些变量
# @property {string} preState 设置统计ui.router.$state.name时所加的前缀，防止可能出现2个application有同样地ui.state
###
analytics.provider('analyticsConfig',()->
  that = @
  @preState = ""
  @$get = ()->
    return {
      preState:(value)->
        if value 
          that.preState = value 
        return if that.preState then that.preState+ "." else '' 

    }
  return @
)
#事件响应并统计
analytics.run(['$rootScope','$log','analyticsConfig',($rootScope,$log,analyticsConfig)->
  console.log 
  if !window.ga 
    window.ga = ()->
      return ;
  #登录analyticsConfig
  $rootScope.$on('authenticated',(evt,param)->
    user = param.user
    ga('set','&uid',user.id)
  )
  #切换视图
  $rootScope.$on('$stateChangeSuccess',(evt, toState)->
    title =  $rootScope.title || document.title
    page = analyticsConfig.preState() + toState.name|| window.location.pathname
    $log.log 'pageview',page,'title',title
    ga('send', 'pageview',{title,page,location:page})
    ga('set','location','')
    # setTimeout(()->
    #   selects = ["input[type='button']","button","a"]
    #   for select in selects 
    #     buttons = $(select)
    #     for btn in buttons
    #       if !btn.attributes.ga && ( select isnt 'a' or !(!btn.attributes.href and !btn.attributes["ng-href"] and !btn.attributes["ng-click"])) 
    #         # console.log btn
    #         ;
    #   return ;
    # ,1000)
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
