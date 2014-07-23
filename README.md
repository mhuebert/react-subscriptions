
# react-subscriptions

Allows a component to subscribe to data. Whenever the data changes, it is set into the component's state.

Get started: 

1. Define a function at the component's `statics.subscriptions` which returns a hash of subscription objects. 

2. Each subscription object **must** define `subscribe` and `unsubscribe` methods. It may optionally define `shouldUpdateSubscription` and `default` methods.

### Example:

In the following example, whenever the subscription object fires its callback with new data, that data will be set into `state.users`.

```(coffeescript)

    SubscriptionMixin = require("react-subscriptions")
    React.createClass
        mixins: [SubscriptionMixin]
        statics: ->
            subscriptions: (props) ->
                users:
                    subscribe: (callback) -> 
                        ...get data...
                        callback(err, data)
                    unsubscribe: ->
                        ...clean up...
                    shouldUpdateSubscription: (oldProps, newProps) ->
                        ...when props change, decide whether to reset subscription...
                    default: -> 
                        ...return default value for prop, before data arrives...
```