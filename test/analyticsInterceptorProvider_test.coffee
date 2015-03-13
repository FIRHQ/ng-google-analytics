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
      expect(dsc).toEqual("method:post,params:"+JSON.stringify(params)+",headers:headers,result:ttttt")
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
    it("sendExceptionWithEvent test",()->
      r = provider.$sendExceptionWithEvent(error)
      expect(hasSend).toBeFalsy()
      expect(r).toBeFalsy()
    )
    it("sendException test",()->
      r = provider.$sendException(error)
      expect(hasSend).toBeFalsy()
      expect(r).toBeFalsy()
    )
  )
  describe("exclude test",()->
    it("add once",inject(()->
      provider.addExclude({"/api/v2/app":"401"})
      expect(provider.getExclude()).toEqual({"/api/v2/app":["401"]})
    ))
    it("add array",inject(()->
      provider.addExclude([{"/api/v2/app":"401"},{"/api/v2/sign":"401"}])
      expect(provider.getExclude()).toEqual({"/api/v2/app":["401"],"/api/v2/sign":["401"]})
    ))
    it("add same url",inject(()->
      provider.addExclude([{"/api/v2/app":"401"},{"/api/v2/app":"403"}])
      expect(provider.getExclude()).toEqual({"/api/v2/app":["401","403"]})
    ))
    it("add same url with array",inject(()->
      provider.addExclude([{"/api/v2/app":["401","403"]},{"/api/v2/sign":"403"}])
      expect(provider.getExclude()).toEqual({"/api/v2/app":["401","403"],"/api/v2/sign":["403"]})
    ))
    it("add error params",inject(()->
      provider.addExclude("xxxxxx")
      expect(provider.getExclude()).toEqual({})
    ))
  )
  describe("exclude url status",()->
    beforeEach(()->
      window.ga = (method,action,type,description,url)->


    )
    it("all include",()->
    )
  )
  describe("fir stop send by sendWithEvent",()->
    beforeEach(()->
      provider.beforeSend = (error)->
        url = error.url
        status = error.status
        if provider.isHostRequest(url)
          if /\/user\/signin/.test url and status is 401
            return false
        else 
          return true
    )
  )
)