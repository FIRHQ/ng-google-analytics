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

  it("sendWith Event",inject(()->

  ))
)