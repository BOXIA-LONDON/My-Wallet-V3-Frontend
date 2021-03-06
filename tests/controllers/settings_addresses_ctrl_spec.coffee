describe "SettingsAddressesCtrl", ->
  $q = undefined
  $state = undefined
  scope = undefined
  Wallet = undefined
  Alerts = undefined
  MyBlockchainApi = undefined
  Labels = undefined

  beforeEach angular.mock.module("walletApp")

  modal =
    open: ->

  beforeEach ->
    angular.mock.inject ($injector, $rootScope, $controller, _$q_) ->
      $q = _$q_
      $state = $injector.get('$state')
      Wallet = $injector.get("Wallet")
      Alerts = $injector.get("Alerts")
      MyBlockchainApi = $injector.get("MyBlockchainApi")
      Labels = $injector.get("Labels")

      account =
        index: 0
        receiveIndex: 3
        receiveAddressAtIndex: (i) -> 'addr_at_index_' + i

      Wallet.accounts = () -> [account]
      Wallet.status = {isLoggedIn: true}

      MyBlockchainApi.getBalances = (addrs) ->
        response = {}
        for addr in addrs
          response[addr] =
            address: addr
            n_tx: 1
            final_balance: 1000
        $q.resolve(response)

      scope = $rootScope.$new()

      $controller "SettingsAddressesCtrl",
        $scope: scope,
        $state: $state,
        $stateParams: { account: 0 }
        Wallet: Wallet
        Labels: Labels
        $uibModal: modal

  it "should have payment requests", ->
    expect(scope.addresses.length).toEqual(4)

  it "should calculate total number of past addresses", ->
    expect(scope.totalPast).toEqual(4)

  it "should open modal to edit an account", ->
    spyOn(modal, "open")
    scope.editAccount(scope.account)
    expect(modal.open).toHaveBeenCalled()

  it "should open modal to reveal the xpub", ->
    spyOn(modal, "open")
    scope.revealXpub(scope.account)
    expect(modal.open).toHaveBeenCalled()

  describe "createAddress", ->
    it "should label the next receive address", ->
      spyOn(Labels, 'addLabel').and.callThrough()
      scope.createAddress()
      expect(Labels.addLabel).toHaveBeenCalled()
      expect(Labels.addLabel.calls.argsFor(0)[0]).toEqual(0)

  describe "removeAddressLabel", ->
    it "should prompt the user before removing the label", ->
      spyOn(Alerts, "confirm").and.callThrough()
      scope.removeAddressLabel()
      expect(Alerts.confirm).toHaveBeenCalled()

    it "should remove the address label", ->
      spyOn(Alerts, "confirm").and.returnValue($q.resolve())
      spyOn(Labels, 'removeLabel').and.callThrough()
      scope.removeAddressLabel(2, 0)
      scope.$digest()
      expect(Labels.removeLabel).toHaveBeenCalledWith(0, 2)

  describe "toggleShowPast", ->
    it "should prompt the user to confirm when showing past addresses", ->
      spyOn(Alerts, 'confirm').and.returnValue($q.resolve())
      scope.toggleShowPast()
      expect(Alerts.confirm).toHaveBeenCalled()
      scope.$digest()
      expect(scope.showPast).toEqual(true)

    it "should toggle off", ->
      scope.showPast = true
      scope.toggleShowPast()
      expect(scope.showPast).toEqual(false)

  describe "setPastAddressesPage", ->
    beforeEach ->
      spyOn(Labels, 'fetchBalance').and.callThrough()

    it "should fetch the balance for the first page of addresses", ->
      scope.addresses = Labels.all(0)

      expectedFirstPage = [scope.addresses[3]]
      scope.pageLength = 1
      scope.setPastAddressesPage(1)
      expect(Labels.fetchBalance).toHaveBeenCalledWith(expectedFirstPage)

  it "should redirect to accounts page if account is archived", inject(($state) ->
    spyOn($state, "go").and.callThrough()
    scope.account.archived = true
    scope.$digest()
    expect($state.go).toHaveBeenCalledWith('wallet.common.settings.accounts_index')
  )
