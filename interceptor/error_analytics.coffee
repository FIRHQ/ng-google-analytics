# analytics.value('ga',window.ga)
#拦截错误的请求，并统计
###*
# @ngdoc object
# @name fir.analytics.analyticsInterceptor
# @description
# 错误分析拦截器，请在所有要拦截错误的module中注入,统计的url会进行处理：
# url = url.replace(/token=\w{40}/,":token").replace(/\w{24}/,":id").replace(/\w{24}/,":id")
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
analytics.factory("analyticsInterceptor",['$q',($q)->
  return {
    responseError:(resq)->
      #不记录params列表
      # params = resq.config.params || {}
      
      #替换url中可能存在的id
      url = resq.config.url
      url = url.replace(/token=\w{40}/,":token").replace(/\w{24}/,":id").replace(/\w{24}/,":id")
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