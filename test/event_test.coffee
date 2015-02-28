describe('googla analytics 指令测试',()->
  $compile = null
  $rootScope = null

  beforeEach(module('fir.analytics'))
  beforeEach(inject((_$compile_, _$rootScope_)->
    $compile = _$compile_;
    $rootScope = _$rootScope_;
  ))
  describe('ga基础指令测试',()->
    it('button name first 1 ',()->
      ele = "<button ga-type='test' ga-event ga ga-name='test_btn'/>"
      $element = angular.element(ele)

      $scope = $rootScope.$new()
      template = $compile($element)($scope)

      $scope.$digest()
      ctrl = $scope.controller
      gaEle = ctrl.getGaElement()
      expect(gaEle.type).toBe('test')
      expect(gaEle.name).toBe('test_btn')
    )
    it('button name first 2',()->
      ele = "<button ga-type='test' type='button' ga-event ga ga-name='test_ta_btn' name='test_name_btn'/>"
      $element = angular.element(ele)

      $scope = $rootScope.$new()
      template = $compile($element)($scope)

      $scope.$digest()
      ctrl = $scope.controller
      gaEle = ctrl.getGaElement()
      expect(gaEle.type).toBe('test')
      expect(gaEle.name).toBe('test_ta_btn')
    )
    it('button name first 3 ',()->
      ele = "<button type='button' ga-event ga ga-name='test.test_ta_btn' id='test_btn'/>"
      $element = angular.element(ele)

      $scope = $rootScope.$new()
      template = $compile($element)($scope)

      $scope.$digest()
      ctrl = $scope.controller
      gaEle = ctrl.getGaElement()
      expect(gaEle.type).toBe('test')
      expect(gaEle.name).toBe('test_ta_btn')
    )
    it('input name first 4 ',()->
      ele = "<input type='checkbox' ga-event ga name='test.checkbox.btn'/>"
      $element = angular.element(ele)

      $scope = $rootScope.$new()
      template = $compile($element)($scope)

      $scope.$digest()
      ctrl = $scope.controller
      gaEle = ctrl.getGaElement()
      expect(gaEle.type).toBe('test')
      expect(gaEle.name).toBe('checkbox.btn')
    )
  )
  describe('ga event指令测试',()->
    it('one event test',()->
      ele = "<input type='button' ga ga-event='click' ga-name='test_btn'>"
      $scope = $rootScope.$new()
      template = $compile(ele)($scope)
      $scope.$digest()
      ctrl = $scope.controller
      gaEle = ctrl.getGaElement()
      expect(gaEle.type).toBe('button')
      expect(gaEle.name).toBe('test_btn')
      expect(gaEle.events).toContain('click')
    )
    it('array event test',()->
      ele = "<input type='button' ga ga-event='click,blur,focus' ga-name='test_btn'>"
      $scope = $rootScope.$new()
      template = $compile(ele)($scope)
      $scope.$digest()
      ctrl = $scope.controller
      gaEle = ctrl.getGaElement()
      expect(gaEle.type).toBe('button')
      expect(gaEle.name).toBe('test_btn')
      expect(gaEle.events).toContain('click')
      expect(gaEle.events).toContain('focus')
      expect(gaEle.events).toContain('blur')
    )
  )
)
