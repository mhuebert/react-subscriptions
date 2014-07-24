ReactAsync = require("react-async")
async = require("async")

setSubscriptionStateCallback = (owner, path, defaultData) ->
  (data) ->
    state = {}
    state[path] = data || defaultData
    owner.setState(state)

fetchOnce = (subscription) ->
  (callback) ->
    subscription.subscribe (data) ->
      subscription.unsubscribe()
      callback(null, data||subscription.default)

module.exports =
  mixins: [ReactAsync.Mixin]
  subs: (path) ->
    @state[path] || @constructor.subscriptions?(this.props)[path].default
  getInitialStateAsync: (cb) ->
    return if window?
    @__subscriptions = {}
    tasks = {}
    subscriptions = @constructor.subscriptions?(this.props)
    for path, subscription of subscriptions
      @__subscriptions[path] = subscription
      tasks[path] = fetchOnce(subscription)
    async.parallel tasks, (err, results) ->
      cb(null, results)
  subscribe: (props) ->
    @__subscriptions = {}
    for path, subscription of @constructor.subscriptions?(props)
      do (path, subscription) =>
          subscription.subscribe setSubscriptionStateCallback(this, path, subscription.default)
          @__subscriptions[path] = subscription

  unsubscribe: ->
    for path, subscription of @__subscriptions
      subscription.unsubscribe()
      delete @__subscriptions[path]
  componentDidMount: ->
    @subscribe(this.props)
  componentWillUnmount: ->
    @unsubscribe()
  componentWillReceiveProps: (newProps) ->
    pathsToUpdate = []
    for path, subscription of @__subscriptions
      if subscription.shouldUpdateSubscription?(this.props, newProps)
        pathsToUpdate.push(path)
    if pathsToUpdate.length > 0
      newSubscriptions = @constructor.subscriptions(newProps)
      for path in pathsToUpdate
        @__subscriptions[path].unsubscribe()
        @__subscriptions[path] = newSubscriptions[path]
        @__subscriptions[path].subscribe setSubscriptionStateCallback(this, path)