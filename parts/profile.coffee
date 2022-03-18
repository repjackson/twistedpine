if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'profile'
    Router.route '/user/:username/dashboard', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/products', (->
        @layout 'user_layout'
        @render 'user_products'
        ), name:'user_products'
    Router.route '/user/:username/credit', (->
        @layout 'user_layout'
        @render 'user_credit'
        ), name:'user_credit'
    Router.route '/user/:username/orders', (->
        @layout 'user_layout'
        @render 'user_orders'
        ), name:'user_orders'
    Router.route '/user/:username/messages', (->
        @layout 'user_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/favorites', (->
        @layout 'user_layout'
        @render 'user_favorites'
        ), name:'user_favorites'
    Router.route '/user/:username/health', (->
        @layout 'user_layout'
        @render 'user_health'
        ), name:'user_health'
    Router.route '/user/:username/notifications', (->
        @layout 'user_layout'
        @render 'user_notifications'
        ), name:'user_notifications'
    Router.route '/user/:username/food', (->
        @layout 'user_layout'
        @render 'user_food'
        ), name:'user_food'
    Router.route '/user/:username/friends', (->
        @layout 'user_layout'
        @render 'user_friends'
        ), name:'user_friends'



    Template.user_favorites.onCreated ->
        @autorun -> Meteor.subscribe 'user_favorited_docs', Router.current().params.username, ->


    Template.user_favorites.helpers
        favorited_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                _id: $in: user.favorite_ids
if Meteor.isServer
    Meteor.publish 'user_favorited_docs', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            _id: $in: user.favorite_ids
        
if Meteor.isClient
    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username

    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.user_layout.helpers
        user_from_username_param: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

    Template.logout_other_clients_button.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

    Template.logout_button.events
        'click .logout': (e,t)->
            Meteor.call 'insert_log', 'logout', Meteor.userId(), ->
                
            Router.go '/login'
            $(e.currentTarget).closest('.grid').transition('slide left', 500)
            
            Meteor.logout()
            $('body').toast({
                title: "logged out"
                # message: 'Please see desk staff for key.'
                class : 'success'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
            
