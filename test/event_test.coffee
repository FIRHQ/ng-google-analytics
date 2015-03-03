angular.module('fir.analytics').directive('ga',[()->
  restrict: 'A'
  require:"?^gaType" #如果不存在不影响程序的其他正常功能
  priority:1
  link:(scope,elem,attr,controller)->
    scope.attr = attr
    scope.controller = controller
])
describe('googla analytics 指令测试',()->
  $compile = null
  $rootScope = null

  beforeEach(module('fir.analytics'))
  beforeEach(inject((_$compile_, _$rootScope_)->
    $compile = _$compile_;
    $rootScope = _$rootScope_;
  ))
  cp = (elem)->
    $scope = $rootScope.$new()
    element = $compile(elem)($scope)
    controller = $scope.controller
    ga = controller?.getGaElement(element,$scope.attr)
    return {
      elem:element
      ctrl:controller
      ga
    }
  it('baseTest',()->
    ele = "<button ga-type='test' ga-event ga ga-name='test_btn'/>"
    
    obj = cp(ele)
    gaEle = obj.ga
    expect(gaEle.type).toBe('test')
    expect(gaEle.name).toBe('test_btn')
    expect(gaEle.events).toEqual(['click'])
  )
  it('嵌套',()->
    ele = "<div ga ga-type='test'> <button ga ga-event ga ga-name='test_btn'/></div>"
    
    obj = cp(ele)
    parent = obj.elem
    child = parent.find('button')
    gaEle = obj.ctrl.getGaElement(child,child.scope().attr)

    expect(gaEle.type).toBe('test')
    expect(gaEle.name).toBe('test_btn')
  )
  it('no ga-type',()->
    ele = '<button ga ga-event ga-name="asd"></button>'
    obj = cp(ele)
    ga = obj.ga
    expect(ga).not.toBeDefined()
  )
  it('gaEvent auto event',()->
    ele = "<select ga-type='test' ga-event ga ga-name='test_btn' ng-model='test' ng-change='xx=1'><option value='1'>sa</option></select>"
    
    obj = cp(ele)
    gaEle = obj.ga
    expect(gaEle.events).toEqual(['change'])
  )

  it('gaEvent attr',()->
    ele = "<select ga-type='test' ga-event='click' ga ga-name='test_btn' ng-model='test' ng-change='xx=1'><option value='1'>sa</option></select>"
    
    obj = cp(ele)
    gaEle = obj.ga
    expect(gaEle.events).not.toContain(['change'])
    expect(gaEle.events).toEqual(['click'])

  )

)
