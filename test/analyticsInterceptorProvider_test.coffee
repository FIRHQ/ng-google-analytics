describe("analyticsInterceptorProvider 测试用例",()->
  provider = null
  base = null
  error = null
  beforeEach(module('fir.analytics',(analyticsInterceptorProvider)->
    base = analyticsInterceptorProvider
    return ;
  ))
  beforeEach(inject(()->
    provider = angular.copy(base)
    error = {
      status: 401
      url:"/api/v2/app/info/zzzzzzzzzzzzzzzzzzzzzzzzzzzz"
      params:{email:"tttttt",password:"111111"}
      headers:{"Accept":"application/json, text/plain, */*"}
      result:{
        message:"user not exist"
        code:"31"
      }
    }
    return ;
  ))
  oldGa = angular.noop
  beforeEach(()->
    oldGa = window.ga
  )
  afterEach(()->
    window.ga = oldGa
  )
  it("replace test",inject(()->
    error.url = "http://noodles.bughd.com/api/user?access_token=55012ed9a6c2d7df18000b2131df81de"
    provider.replaceMethod(error)
    expect(error.url).toEqual("http://noodles.bughd.com/api/user?access_token=:token")

    error.url = "/api/v2/app/55012ed9a6c2d7df18000b21/install"
    provider.replaceMethod(error)
    expect(error.url).toEqual("/api/v2/app/:id/install")

    error.url = "/api/v2/app/55012ed9a6c2d7df18000b21/install?token=55012ed9a6c2d7df18000b2131df81dexxx"
    provider.replaceMethod(error)
    expect(error.url).toEqual("/api/v2/app/:id/install?token=:token")
  
  )) 

  it("replaceMethod test",inject(()->
    o = provider.replaceMethod
    ob = o.bind(provider)
    provider.replaceMethod = (xerror)->
      ob(xerror)
      xerror.url = xerror.url.replace(/short=[\w\d]{3,16}/gi,"short=:short").replace(/appid=[\w\d\.]+/gi,"appid=:appid")
      return xerror
      # analyticsInterceptorProvider.collect.headers = true;
      # analyticsInterceptorProvider.collect.result = true;
    error.url = "/api/v2/app/short/verify?short=www&appid=com.sunboxsoft.deeper.moblie.app.shangdongxs"
    provider.replaceMethod(error)
    expect(error.url).toEqual("/api/v2/app/short/verify?short=:short&appid=:appid")
  ))

  it("hostDomain test",inject(()->
    error.url =  "/api/v2/app/55012ed9a6c2d7df18000b21/install?token=55012ed9a6c2d7df18000b2131df81dexxx"
    expect(provider.isHostRequest(error.url)).toBeTruthy()
    expect(provider.isOtherRequest(error.url)).toBeFalsy()
  ))

  it("hostDomain http://fir.im",inject(()->
    provider.hostDomain = "fir.im"
    error.url =  "http://fir.im/api/v2/app/55012ed9a6c2d7df18000b21/install?token=55012ed9a6c2d7df18000b2131df81dexxx"
    expect(provider.isHostRequest(error.url)).toBeTruthy()
    expect(provider.isOtherRequest(error.url)).toBeFalsy()
  ))
  it("hostDomain substr domain",inject(()->
    provider.hostDomain = "fir.im"
    error.url =  "http://api.fir.im/api/v2/app/55012ed9a6c2d7df18000b21/install?token=55012ed9a6c2d7df18000b2131df81dexxx"
    expect(provider.isHostRequest(error.url)).toBeTruthy()
    expect(provider.isOtherRequest(error.url)).toBeFalsy()
  ))  
  it("hostDomain error substr domain",inject(()->
    provider.hostDomain = "fir.im"
    error.url =  "http://fir.im.api/api/v2/app/55012ed9a6c2d7df18000b21/install?token=55012ed9a6c2d7df18000b2131df81dexxx"
    expect(provider.isHostRequest(error.url)).toBeFalsy()
    expect(provider.isOtherRequest(error.url)).toBeTruthy()
  ))

  it("hostDomain with other domain",inject(()->
    provider.hostDomain = "fir.im"
    error.url =  "http://qiniu.com/api/v2/app/55012ed9a6c2d7df18000b21/install?token=55012ed9a6c2d7df18000b2131df81dexxx"
    expect(provider.isHostRequest(error.url)).toBeFalsy()
    expect(provider.isOtherRequest(error.url)).toBeTruthy()
  ))

  describe("collect method",()->
    dsc = null
    oldParams = null
    syncCollectSetting = (()->
      base.collect = provider.collect
    )
    #所有设置都为空
    beforeEach(()->
      
      collect = {}
      oldParams = base.collect
      c = provider.collect 
      for name,value of c 
        collect[name] = false
      provider.collect = collect
      syncCollectSetting()
      window.ga = (method,action,type,description,url)->
        dsc = description
        return dsc;
    )
    afterEach(()->
      base.collect = oldParams
    )

    it("collect params",inject(()->
      provider.collect.params = true
      syncCollectSetting()
      error.params = params = {email:"tttt@tt.im",password:"xxxxa",id:"asdfasfweqwerw"}
      provider.$sendExceptionWithEvent(error)
      expect(dsc).not.toBeNull()
      expect(dsc).toEqual("params:" + JSON.stringify(params))
    ))    
    it("collect method",inject(()->
      provider.collect.method = true
      syncCollectSetting()
      error.method = method = "post"
      provider.$sendExceptionWithEvent(error)
      expect(dsc).not.toBeNull()
      expect(dsc).toEqual("method:post" )
    ))
    it("collect all",inject(()->
      provider.collect.all = true
      syncCollectSetting()
      error.method = method = "post"
      error.params = params = {email:"tttt@tt.im",password:"xxxxa",id:"asdfasfweqwerw"}
      error.headers= "headers"
      error.result = "ttttt"
      provider.$sendExceptionWithEvent(error)
      expect(dsc).not.toBeNull()
      expect(dsc).toEqual("method:post,params:"+JSON.stringify(params)+",result:ttttt")
    ))
  )

  describe("exclude test",()->
    it("add once",inject(()->
      provider.addExclude({"/api/v2/app":"401"})
      expect(provider.getExclude()).toEqual({"/api/v2/app":[401]})
    ))
    it("add array",inject(()->
      provider.addExclude([{"/api/v2/app":"401"},{"/api/v2/sign":"401"}])
      expect(provider.getExclude()).toEqual({"/api/v2/app":[401],"/api/v2/sign":[401]})
    ))
    it("add same url",inject(()->
      provider.addExclude([{"/api/v2/app":"401"},{"/api/v2/app":"403"}])
      expect(provider.getExclude()).toEqual({"/api/v2/app":[401,403]})
    ))
    it("add same url with array",inject(()->
      provider.addExclude([{"/api/v2/app":["401","403"]},{"/api/v2/sign":"403"}])
      expect(provider.getExclude()).toEqual({"/api/v2/app":[401,403],"/api/v2/sign":[403]})
    ))
    it("add error params",inject(()->
      provider.addExclude("xxxxxx")
      expect(provider.getExclude()).toEqual({})
    ))
  )
)
describe("analyticsInterceptor",()->
  #测试modoule
  angular.module("ai.test",['fir.analytics']).config(($httpProvider)->
    $httpProvider.interceptors.push('analyticsInterceptor')
  ).controller("testCtrl",($scope,$http)->
    ;
  )
  # MyController = ($scope,$http)->
  #   $http.get("/api/v2/app",{dd:123}).success((data)->
  #     $scope.d = data.id
  #   ).error(()->
  #     ;
  #   )
  httpBackend = null 
  provider = null
  rootScope = null
  createController = null
  requestHandler = null
  _http = null

  setHttpError = (url,status,method="GET")->
    handle = httpBackend.expect(method,url).respond({message:"ok"})
    handle.respond(parseInt(status),{message:"only test",code:"111"})
  
  getError = (url,status,method="GET")->
    r = null
    error = null
    
    if url and status
      setHttpError(url,status,method)

    config = {
      method:method
      data:{
        p1:1
        p2:2
        p3:3
      }
      url:"/api/v2/error"
    }
    if url
      config.url = url

    _http(config).catch((resq)->
      r = resq.isCollect
      error =resq.collectError
    )
    httpBackend.flush()
    return {
      result:r
      error:error
    }

  beforeEach(module('fir.analytics',(analyticsInterceptorProvider)->
    provider = analyticsInterceptorProvider
    provider.collect.all = true
    o = provider.replaceMethod 
    provider.replaceMethod = (error)->
      o(error)
      error.url = error.url.replace(/short=[\w\d]{3,16}/gi,"short=:shrot").replace(/appid=[\w\d\.]+/gi,"appid=:appid")
      return error
    return ;
  ))
  beforeEach(module("ai.test"))
  beforeEach(inject(($httpBackend,$rootScope,$injector,$http)->
    httpBackend = $httpBackend
    rootScope = $rootScope
    _http=$http

    getHandler = httpBackend.whenGET("/api/v2/error").respond({message:'ok'})
    getHandler.respond(403,{message:"only test",code:"301"})

    postHandler = httpBackend.whenPOST("/api/v2/error").respond({message:'ok'})
    postHandler.respond(403,{message:"only test",code:"301"})
    # requestHandler = httpBackend.whenGET("/api/v2/app").respond({id:'xxx'})
  ))
  afterEach(()->
    httpBackend.verifyNoOutstandingExpectation()
    httpBackend.verifyNoOutstandingRequest();
    provider.$clearExclude()
  ) 
  it("http test with normal",inject(($http)->
    httpBackend.expectGET("/api/v2/app").respond({id:'yyyy'})  #优先响应此方法，与位置无关
    d = null
    $http.get("/api/v2/app",{dd:123}).success((data)->
      d = data.id
    ).error(()->
      ;
    )
    httpBackend.flush()
    expect(d).toEqual("yyyy")
  )) 
  describe("event model",()->
    beforeEach(()->
      provider.model = "event"
    )
    it("not in exclude, send",inject(($http)->
      provider.addExclude({"/api/v2/app":["401","403"]})
      RequestHandler = httpBackend.whenGET("/api/v2/app").respond({message:'ok'})
      RequestHandler.respond(400,{message:"only test",code:"301"})
      ic = null
      error = null
      $http.get("/api/v2/app",{name:"xxx",password:"12345"}).then((rs)->
        ;
      ).catch((resq)->
        ic = resq.isCollect
        error = resq.collectError
      )
      httpBackend.flush()
      expect(ic).not.toBeNull()
      expect(ic).toBeTruthy()
      expect(error.status).toEqual(400)
    ))  
    it("in exclude,not send",inject(($http)->
      provider.addExclude({"/api/v2/app":["401","403"]})
      RequestHandler = httpBackend.whenGET("/api/v2/app").respond({message:'ok'})
      RequestHandler.respond(401,{message:"only test",code:"301"})
      ic = null
      $http.get("/api/v2/app",{name:"xxx",password:"12345"}).then((rs)->
        ;
      ).catch((resq)->
        ic = resq.isCollect
      )
      httpBackend.flush()
      expect(ic).not.toBeNull()
      expect(ic).toBeFalsy()
    ))
    it("beforeSend false,not send",inject(($http)->
      provider.beforeSend = ()->
        return false
      RequestHandler = httpBackend.whenGET("/api/v2/app").respond({message:'ok'})
      RequestHandler.respond(401,{message:"only test",code:"301"})
      ic = null
      $http.get("/api/v2/app",{name:"xxx",password:"12345"}).then((rs)->
        ;
      ).catch((resq)->
        ic = resq.isCollect
      )
      httpBackend.flush()
      expect(ic).not.toBeNull()
      expect(ic).toBeFalsy()
    ))
  )
  describe("exception model",()->
    beforeEach(()->
      provider.model = "exception"
    ) 
    it("not in exclude, send",inject(($http)->
      provider.addExclude({"/api/v2/app":["401","403"]})
      RequestHandler = httpBackend.whenGET("/api/v2/app").respond({message:'ok'})
      RequestHandler.respond(400,{message:"only test",code:"301"})
      ic = null
      error = null
      $http.get("/api/v2/app",{name:"xxx",password:"12345"}).then((rs)->
        ;
      ).catch((resq)->
        ic = resq.isCollect
        error = resq.collectError
      )
      httpBackend.flush()
      expect(ic).not.toBeNull()
      expect(ic).toBeTruthy()
      expect(error.status).toEqual(400)
    ))  
    it("in exclude,not send",inject(($http)->
      provider.addExclude({"/api/v2/app":["401","403"]})
      RequestHandler = httpBackend.whenGET("/api/v2/app").respond({message:'ok'})
      RequestHandler.respond(401,{message:"only test",code:"301"})
      ic = null
      $http.get("/api/v2/app",{name:"xxx",password:"12345"}).then((rs)->
        ;
      ).catch((resq)->
        ic = resq.isCollect
      )
      httpBackend.flush()
      expect(ic).not.toBeNull()
      expect(ic).toBeFalsy()
    ))
    it("beforeSend false,not send",inject(($http)->
      provider.beforeSend = ()->
        return false
      RequestHandler = httpBackend.whenGET("/api/v2/app").respond({message:'ok'})
      RequestHandler.respond(401,{message:"only test",code:"301"})
      ic = null
      $http.get("/api/v2/app",{name:"xxx",password:"12345"}).then((rs)->
        ;
      ).catch((resq)->
        ic = resq.isCollect
      )
      httpBackend.flush()
      expect(ic).not.toBeNull()
      expect(ic).toBeFalsy()
    ))
  )
  describe("formdata test",()->
    defaults = null
    beforeEach(()->
      provider.model = "event"
    )
    beforeEach(inject(($http)->
      defaults = $http.defaults
    ))
    gconfig = null
    initConfig = (config,$http)->
      config.method = 'POST'
      config.headers = config.headers || {}
      config.headers['Content-Type'] = undefined #b必须
      gconfig = config
      
      origTransformRequest = defaults.transformRequest;
      origData = config.data;
      formData = new FormData();
      config.transformRequest = (data,headersGetter)->
        if origData #参数中data为转成formData之后的，所以必须使用之前保存的origData
          for key,val of origData
            if (typeof origTransformRequest is 'function') 
              val = origTransformRequest(val, headersGetter);
            else 
              for transformFn in  origTransformRequest
                if (typeof transformFn is 'function') 
                  val = transformFn(val, headersGetter);
            formData.append(key, val);
        return formData

      config.data = formData

      return config

    transformRequest = (data,headersGetter)->
      formData = new FormData();
      angular.forEach(data,(v,k)->
        vl = v
        if vl then formData.append(k,vl)
      )
      gconfig.data = formData
      return formData

    it("Content-Type",inject(($http)->
      config = {
        url:"/api/v2/error"
        data:{
          key:"123123123"
          bund:"zzzzzz"
          file:new Blob()
        }
      }
      config.gaParams = config.data

      initConfig(config)
      $http(config).then(()->
        ;
      ).catch((resq)->
        # can't reader params
        error = resq.collectError
        expect(error.params.bund).toEqual(config.gaParams.bund)
        expect(error.params.key).toEqual(config.gaParams.key)
        # expect(error.file).toEqual("[object Blob]")
      )
      httpBackend.flush()
    ))
  )

  describe("stop send",()->
    hasSend =false
    
    beforeEach(()->
      window.ga = ()->
        hasSend = true
      provider.beforeSend = ()->
        return false
    )
    afterEach(()->
      hasSend = false
    )
    it("sendExceptionWithEvent test",inject(($http)->
      provider.model = "event"
      obj = getError()
      expect(hasSend).toBeFalsy()
      expect(obj.result).toBeFalsy()
    ))
    it("sendExceptionWithEvent success test",()->
      provider.beforeSend = ()->
        return true
      provider.model = "event"
      obj = getError()
      expect(hasSend).toBeTruthy()
      expect(obj.result).toBeTruthy()
    )
    it("sendException test",()->
      provider.model = "exception"
      obj = getError()
      expect(hasSend).toBeFalsy()
      expect(obj.result).toBeFalsy()
    )
    it("sendException success test",()->
      provider.beforeSend = ()->
        return true
      provider.model = "exception"
      obj = getError()
      expect(hasSend).toBeTruthy()
      expect(obj.result).toBeTruthy()
    )
  )

  describe("exclude url status",()->
    error = {}
    it("all send",inject(()->
      provider.addExclude([{"/api/v2/app":["401","403"]},{"/api/v2/sign":"403"}])

      #other url
      error.url = "/api/v2/app/id"
      error.status = "403"

      obj = getError(error.url,error.status)
      expect(obj.result).toBeTruthy()

      error.url = "/api/app"
      error.status = "403"
      obj = getError(error.url,error.status)
      expect(obj.result).toBeTruthy()

      #other status
      error.url = "/api/v2/app"
      error.status = "400"
      obj = getError(error.url,error.status)
      expect(obj.result).toBeTruthy()

    ))
    it("all not send",inject(()->
      provider.addExclude([{"/api/v2/app":["401","403"]},{"/api/v2/sign":"403"}])
      #other url
      error.url = "/api/v2/app"
      error.status = "401"
      obj = getError(error.url,error.status)
      expect(obj.result).toBeFalsy()

      error.url = "/api/v2/sign"
      error.status = "403"
      obj = getError(error.url,error.status)
      expect(obj.result).toBeFalsy()
    ))
    it("replace url ,not send",inject(()->
      provider.addExclude([{"/api/v2/app?token=:token":["401","403"]},{"/api/v2/sign":"403"}])
      error.url = "/api/v2/app?token=xq23214rwefwfasdfaszx"
      error.status = "401"
      obj = getError(error.url,error.status)
      expect(obj.result).toBeFalsy()
    ))
  )
  describe("collect",()->
    error = {}
    it("URL params",inject(()->
      provider.addExclude([{"/api/v2/app?token=:token":["401","403"]},{"/api/v2/sign":"403"}])
      error.url = "/api/v2/app?token=xq23214rwefwfasdfaszx"
      error.status = "400"
      obj = getError(error.url,error.status)
      expect(obj.result).toBeTruthy()
      expect(obj.error.params).not.toBeNull()
      expect(obj.error.params.token).toEqual("xq23214rwefwfasdfaszx")
    ))
    it("URL params",inject(()->
      error.url = "/api/v2/app?token=xq23214rwefwfasdfaszx&email=drt@dgg.com"
      error.status = "400"
      obj = getError(error.url,error.status)
      expect(obj.result).toBeTruthy()
      expect(obj.error.params).not.toBeNull()
      expect(obj.error.params.token).toEqual("xq23214rwefwfasdfaszx")
      expect(obj.error.params.email).toEqual("drt@dgg.com")
      
      error.url = "/api/v2/app?token=xq23214rwefwfasdfaszx&pwd=&email=drt@dgg.com"
      error.status = "400"
      obj = getError(error.url,error.status)
      expect(obj.result).toBeTruthy()
      expect(obj.error.params).not.toBeNull()
      expect(obj.error.params.token).toEqual("xq23214rwefwfasdfaszx")
      expect(obj.error.params.email).toEqual("drt@dgg.com")
      expect(obj.error.params.pwd).toBeNull()
    ))
  )
)