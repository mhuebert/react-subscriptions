
###

    Fetch data (once) from multiple subscription objects and put all results into a single object.

###

_ = require("underscore")
async = require("async")

module.exports = (subscriptions, fetchCallback) ->

    # Make a list out of the subscription hash.
    list = _.chain(subscriptions)
            .pairs()
            .map((pair)->
                if !pair[1].server
                    return false
                _.extend pair[1], path: pair[0])
            .value().filter(Boolean)
    
    # Fetch data using subscribe(), then immediately unsubscribe().
    getData = (subscription, callback) ->
        subscription.subscribe (data) ->
            object = {}
            object[subscription.path] = data
            callback(null, object)
            subscription.unsubscribe()
        , {wait: true}

    # Fetch concurrently & Put results into an object with a 
    # structure that mirrors the original hash.
    async.map list, getData, (err, data) ->
        object = {}
        for result in data
            _.extend object, result
        fetchCallback(object)