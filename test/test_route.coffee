angular.module('test',['fir.analytics','ui.router','ng'])
angular.module('test').config [
  "$stateProvider"
  "$urlRouterProvider"
  ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise('/')
    $stateProvider.state('test1',
      url: "/"
      template: '<div>xxxxx</div>'
    ).state('test2',
      url: "/test"
      template: '<div>zzzzz</div>'
    )
  ]