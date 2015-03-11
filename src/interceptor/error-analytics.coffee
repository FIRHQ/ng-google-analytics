#拦截错误的请求，并统计

###*
# @ngdoc object
# @name fir.analytics.analyticsInterceptorProvider
# @description
# 包含analyticsInterceptor相关设置
###
angular.module('fir.analytics').provider("analyticsInterceptor",[()->
  that = @
  # setting

  ###*
  # @ngdoc property
  # @name isReplace
  # @propertyOf fir.analytics.analyticsInterceptorProvider
  # @description - boolean - 用于设置是否替换，如果设置为true则会调用replaceMethod方法
  ###
  @isReplace = true

  ###*
  # @ngdoc property
  # @name collect
  # @type {object}
  # @propertyOf fir.analytics.analyticsInterceptorProvider
  # @description 用于设置收集信息的类型
  # 
  # - {boolean} - params - 设置是否收集请求的参数 默认为false
  # - {method} - method - 设置是否收集method 默认为true
  # - {status} - status - 设置是否时候请求状态 默认为true
  ###
  #是否收集(参数、方法、状态)信息
  @collect = {
    params:false  #参数
    method:true #方法
    status:true #状态
    headers:false #请求的头
  }
  ###*
  # @ngdoc function
  # @name replaceMethod
  # @methodOf fir.analytics.analyticsInterceptorProvider
  # @description
  # 替换默认错误方法,改方法多用与替换url中得私密信息,默认正则替换如下：
  # url.replace(/token=\w+/,"token=:token").replace(/\w{24}/,":id").replace(/\w{24}/,":id")
  # 
  # 如果需要，可覆盖重写改方法  
  # @param {object} error 错误请求的详细信息,包含以下字段:
  # 
  # - {string} - url - 请求的url
  # - {string} - method - 请求的方法（post、get、update...)
  # - {string} - params - 请求的参数
  # - {number} - status - 错误请求的code
  # @retrun {object} error 字段包含同上
  ###
  #default replace method
  @replaceMethod = (error)->
    #替换url中可能存在的id
    url = error.url 
    error.url = url.replace(/token=\w+/,"token=:token").replace(/\w{24}/,":id").replace(/\w{24}/,":id")
    return error
  ###*
  # @ngdoc property
  # @name model
  # @propertyOf fir.analytics.analyticsInterceptorProvider
  # @description 用于设置已哪中方式设置，可选值如下
  # 
  # - "exception" : 默认，已异常的方式发送，所有得异常信息都统计在异常说明字段，150字以内
  # - "event": 已事件方式发送，默认exception，对应信息如下：
  # - - 事件类别:"exception_event"(固定)
  # - - 事件操作:异常说明
  # - - 事件标签:异常url
  ###
  @model = 'exception' 
  ###*
  # 将error对象根据collect设置转成string
  ###
  collectParamsToString = (error)->
    description = ""
    for name,setting of that.collect
      if setting 
        value = error[name]
        if !value
          value = "undefined"
        else if angular.isObject(value)
          value = JSON.stringify(value)
        description+=",#{name}:" + value
    # description = if description.length > 1 then description.substr(1) else description
    return description
  ###*
  # @ngdoc function
  # @name $sendExceptionWithEvent
  # @methodOf fir.analytics.analyticsInterceptorProvider
  # @description
  # private 已事件方式发送
  # 
  # 如果需要，可覆盖重写改方法  
  # @param {object} error 错误请求的详细信息
  ###
  @$sendExceptionWithEvent = (error)->
    description = collectParamsToString(error)
    description = if description.length > 1 then description.substr(1) else description
    #category,action,name
    ga('send','event',"exception_event",description,error.url)
    
  ###*
  # @ngdoc function
  # @name $sendException
  # @methodOf fir.analytics.analyticsInterceptorProvider
  # @description
  # private 已异常方式发送
  # 
  # 如果需要，可覆盖重写改方法  
  # @param {object} error 错误请求的详细信息
  ###
  @$sendException = (error)->
    description = "url:#{error.url}" 
    description += collectParamsToString(error)
    #统计出错
    ga('send','exception',{
      exDescription:description
      exFatal:false
    })  
    return true    
  
  ###*
  # @ngdoc object
  # @name fir.analytics.analyticsInterceptor
  # @description
  # 错误分析拦截器，请在所有要拦截错误的module中注入
  # url中参数过滤token
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

  @$get = ['$q',($q)->
    {
      responseError:(resq)->
        #不记录params列表
        # params = resq.config.params || {}
        error = {
          url : resq.config.url
          method : resq.config.method
          params : resq.config.data
          status : resq.status
          headers:resq.headers
        }
        if that.isReplace
          error = that.replaceMethod(error)

        switch that.model
          when 'event' then that.$sendExceptionWithEvent(error)
          else that.$sendException(error)
        $q.reject(resq)
    }
  ]
  return @
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