#拦截错误的请求，并统计

###*
# @ngdoc object
# @name fir.analytics.analyticsInterceptor
# @description
# 错误分析拦截器，请在所有要拦截错误的module中注入
# <pre>
#   <script>
#   m = angular.module('someModule',['ng'])
#   m.config('$httpProvider',($httpProvider)->
#     $httpProvider.interceptors.push "analyticsInterceptor"
#   )
#   </script>
# </pre>
# @requires $q
###
angular.module('fir.analytics').factory("analyticsInterceptor",['$q',($q)->
  return {
    responseError:(resq)->
      #不记录params列表
      # params = resq.config.params || {}
      
      #替换url中可能存在的id
      url = resq.config.url
      url = url.replace(/token=\w+/,"token=:token").replace(/\w{24}/,":id").replace(/\w{24}/,":id")
      #统计出错
      ga('send','exception',{
        exDescription:url + ' status:' + resq.status
        exFatal:false
        name:"Fir.model"
        version:"3.0"
        url:url
        method:resq.config.method
        requestParam:resq.config.params
      })      
      $q.reject(resq)
  }
])

# https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers.onerror
  # _pre = window.onerror
# window.onerror = (msg,url,line,col,errorObj)->
#   console.log '错误消息',msg
#   console.log 'url',url
#   console.log 'line',line
#   console.log 'col',col
#   console.log 'obj',errorObj
#   window.preError = errorObj
#   return _pre(msg,url,line,col,errorObj);

# analytics.value('ga',window.ga)