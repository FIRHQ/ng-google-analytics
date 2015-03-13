#拦截错误的请求，并统计

###*
# @ngdoc object
# @name fir.analytics.analyticsInterceptorProvider
# @description
# 包含analyticsInterceptor相关设置
# 发送统计完整流程 replaceMethod()->exclude检查->beforeSend()->发送，其中如果exclude结果为true停止，beforeSend()为false停止。
# 
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
  # - {status|delete} - status - 设置是否收集请求状态 默认为true(已删除，相关信息品在url后方)
  # - {status} - headers - 设置是否收集请求报文头 默认为false
  # - {status} - result - 设置是否收集请求的返回结果 默认为false
  # - {status} - all - 统一设置 默认为false
  ###
  #是否收集(参数、方法、状态)信息
  @collect = {
    params:false  #参数
    method:true #方法
    # status:true #状态，记在url中 
    headers:false #请求的头
    result:false #返回的结果
    all:false #是否统计所有
  }
  #转成字符串时字段顺序
  order = ["method","params","headers","result"]
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
    error.url = url.replace(/token=\w+/gi,"token=:token").replace(/\w{24}/gi,":id").replace(/\w{24}/,":id")
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
    all = that.collect.all
    for name in order
      setting = that.collect[name]
      if all or setting
        value = error[name]
        if !value
          value = "undefined"
        else if angular.isObject(value)
          value = JSON.stringify(value)
        description+=",#{name}:" + value
    # description = if description.length > 1 then description.substr(1) else description
    return description
  ###*
  # @ngdoc property
  # @name exclude
  # @propertyOf fir.analytics.analyticsInterceptorProvider
  # @description
  # 排除的统计列表，值应该为{url:status} 模式,在执行次过滤之前会先replaceMehtod方法，用于统一某些url
  ###
  exclude = {}
  ###*
  # @ngdoc function
  # @name addExclude
  # @methodOf fir.analytics.analyticsInterceptorProvider
  # @description
  # 发送统计前调用，如果返回false、null、undefined将不会发送统计,可在config中覆盖
  # @param {object|array} 此对象应该为以下结构{url : status| [status]}({地址：请求状态或状态数组}) 或为该结构数组
  # @return {this}  链式。返回当前对象
  ###
  @addExclude = (objs)->
    if !angular.isArray(objs) and angular.isObject(objs)
      objs = [objs]
    if angular.isArray objs
      for obj in objs
        for name,value of obj
          status = exclude[name]
          status = status || []
          #缺乏重复性检查
          if angular.isString value
            status.push value
          else if angular.isArray value 
            status = Array.prototype.concat(status,value)
          else
            continue
          exclude[name] = status
    return @
  @getExclude = ()->
    return exclude;
  @isInExclude = (url,status)->
    ;
  ###*
  # @ngdoc function
  # @name beforeSend
  # @methodOf fir.analytics.analyticsInterceptorProvider
  # @description
  # 发送统计前调用，如果返回false、null、undefined将不会发送统计,可在config中覆盖
  # @param {object} error 错误请求的详细信息
  # @return {boolean} 如果为true则发送统计，false则取消发送此次统计
  ###
  @beforeSend = (error)->
    return true;

  ###*
  # @ngdoc property
  # @name hostDomain
  # @propertyOf fir.analytics.analyticsInterceptorProvider
  # @description 
  # 用于设置当前页面所处得domain域，关联isHostRequest、isOtherRequest方法的判定结果
  ###
  @hostDomain = window.location.host
  
  ###*
  # @ngdoc function 
  # @name isHostRequest
  # @methodOf fir.analytics.analyticsInterceptorProvider
  # @description
  # 用于判断当前url是否与locatoin.host是否同一个
  ###
  @isHostRequest = (url)->
    if !/^http/.test(url)
      return true
    hostReg = new RegExp("://[\\w+\\.]*" + @hostDomain + "/")
    return hostReg.test url
  ###*
  # @ngdoc function 
  # @name isOtherRequest
  # @methodOf fir.analytics.analyticsInterceptorProvider
  # @description
  # 用于判断当前url是否与locatoin.host是否不是同一个
  ###
  @isOtherRequest = (url)->
    return !@isHostRequest(url)
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
    if @beforeSend(error) #等测试用例更改之后将次判定移至公共函数$get的种
      #category,action,name
      ga('send','event',"exception_event",description,error.url+" | "+error.status)
      return true
    return false
    
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
    description = "#{error.url} | #{error.status}" 
    description += collectParamsToString(error)
    #统计出错
    if @beforeSend(error)   #等测试用例更改之后将次判定移至公共函数$get的种
      ga('send','exception',{
        exDescription:description
        exFatal:false
      })  
      return true 
    return false   
  
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
          headers:resq.config.headers
          result:resq.data
        }
        if that.isReplace
          that.replaceMethod(error)
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