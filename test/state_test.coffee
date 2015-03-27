describe('ui.route $state change test',()->
  $compile = null
  $rootScope = null
  state = null 
  timeout = null
  successEvent = null 
  callFn = angular.noop
  hasCallPageView = false 
  config = null 
  beforeEach(module('test'))
  beforeEach(inject((_$compile_, _$rootScope_,$state,analyticsConfig,$timeout)->
    $compile = _$compile_;
    $rootScope = _$rootScope_;
    state = $state
    config = analyticsConfig
    hasCallPageView  = false 
    timeout = $timeout
    #监听事件
    successEvent = $rootScope.$on('$stateChangeSuccess',(evt,toState,toParam,fromState,fromParma)->
      callFn(evt,toState,toParam,fromState,fromParma)
    )
  ))
  afterEach(()->
    $rootScope.$apply();
    timeout.flush()
    callFn = angular.noop
    window.ga = angular.noop
    expect(hasCallPageView).toBeTruthy()
    timeout.verifyNoPendingTasks()
  )
  it("base",()->

    callFn = (evt,toState)->
      expect(toState.name).toBe("test1")
    window.ga = (method,action,options)->
      if method is 'send' and action is 'pageview'
        hasCallPageView = true
        title = options.title
        page = options.page
        expect('test1').toBe(page)
    state.go('test1')
    # expect(state.name).toBe("test2")
  )
  describe('successEvent 统计加前缀',()->

    pageViewCallFn = angular.noop
    beforeEach(()->
      hasCallPageView = false;
      pageViewCallFn = angular.noop
      window.ga = (method,action,options)->
        if method is 'send' and action is 'pageview'
          hasCallPageView = true
          title = options.title
          page = options.page
          pageViewCallFn(page,title)
      config.preState('')
    )
    it('1',()->
      callFn = (evt,toState)->
        expect(toState.name).toBe("test1")

      pageViewCallFn = (page,title)->
        expect('dashboard.test1',).toBe(page)

      config.preState('dashboard')
      state.go('test1')
      $rootScope.$apply();
    )
  )
)