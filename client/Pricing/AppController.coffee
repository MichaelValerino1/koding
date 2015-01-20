class PricingAppController extends KDViewController

  KD.registerAppClass this,
    name  : 'Pricing'
    route : '/Pricing'

  constructor: (options = {}, data) ->

    options.appInfo = title: "Pricing"
    options.view    = new PricingAppView params: options.params
    super options, data

    stripeOptions =
      identifier : 'stripe'
      url        : 'https://js.stripe.com/v2/'

    paypalOptions =
      identifier : 'paypal'
      url        : 'https://www.paypalobjects.com/js/external/dg.js'

    @initAppStorage()

    KodingAppsController.appendHeadElement 'script', stripeOptions, =>
      Stripe.setPublishableKey KD.config.stripe.token
      KodingAppsController.appendHeadElement 'script', paypalOptions, =>
        @emit 'ready'


  initAppStorage: ->

    { appStorageController } = KD.singletons

    appStorage = appStorageController.storage 'Pricing', '2.0.0'

    @ready => @mainView.appStorage = appStorage


  loadPaymentProvider: (callback) -> @ready callback


  handleQuery: (query) ->

    { view } = @getOptions()

    { planTitle, planInterval } = query

    return  unless planTitle and planInterval

    @loadPaymentProvider -> view.continueFrom planTitle, planInterval


