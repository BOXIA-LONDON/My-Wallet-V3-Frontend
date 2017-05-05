describe "Click to highlight directive", ->
  $compile = undefined
  $rootScope = undefined
  element = undefined
  $scope = undefined
  $window = undefined

  beforeEach module('walletDirectives')
  
  beforeEach module("walletApp")

  beforeEach inject((_$compile_, _$rootScope_, _$window_) ->

    $compile = _$compile_
    $rootScope = _$rootScope_
    $window = _$window_
    $scope = $rootScope.$new()

    return
  )

  beforeEach ->
    element = $compile("<span single-click-select>some copy</span>")($rootScope)
    $rootScope.$digest()
    $scope.$apply()
    $scope.browser = {canExecCommand: false}

  it "will check a browser version", ->
    expect($scope.browser.canExecCommand).toBeDefined()

  it "can fire the select function", ->
    spyOn($scope, "select").and.callThrough()
    $scope.select()
    expect($scope.select).toHaveBeenCalled()

  beforeEach ->
    $scope.browser = {canExecCommand: true}

    it "has a browser that can copy to clipboard", ->
      spyOn($scope, "select").and.callThrough()
      $scope.select()
      expect($window.document.execCommand).toHaveBeenCalled()
