if Meteor.isClient
    Router.route '/drinks', (->
        @layout 'layout'
        @render 'drinks'
        ), name:'drinks'

    Template.drinks.onCreated ->
        @autorun => @subscribe 'drink', ->
    Template.drink_view.onCreated ->
        @autorun => @subscribe 'drink_orders',Router.current().params.doc_id, ->
    
    
    Template.drink_orders.helpers
        drink_order_docs: ->
            Docs.find 
                model:'order'
                drink_id:Router.current().params.doc_id




if Meteor.isClient
    Router.route '/drink/:doc_id/', (->
        @layout 'layout'
        @render 'drink_view'
        ), name:'drink_view'
    Router.route '/drink/:doc_id/edit', (->
        @layout 'layout'
        @render 'drink_edit'
        ), name:'drink_edit'

    
    Template.drink_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.drink_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.drink_edit.events
        'click .delete_drink_item': ->
            if confirm 'delete drink?'
                Docs.remove @_id
                Router.go "/drink"

    Template.drinks.helpers
        drink_docs: ->
            Docs.find 
                model:$in:['drink','product']
    Template.drink_view.helpers
        sold_out: -> @inventory < 1
        product_orders: ->
            Docs.find 
                model:'order'
                product_id:Router.current().params.doc_id
        
        
    Template.drink_view.events
        'click .quick_buy': ->
            if confirm 'quick buy?'
                new_id = 
                    Docs.insert 
                        model:'order'
                        product_id:@_id
                
        
    Template.drink_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
    Template.drink_view.events
        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'cart_item'
        #         drink_id:@_id
        #     $('body').toast({
        #         title: "#{@title} added to cart."
        #         # message: 'Please see desk staff for key.'
        #         class : 'green'
        #         # position:'top center'
        #         # className:
        #         #     toast: 'ui massive message'
        #         displayTime: 5000
        #         transition:
        #           showMethod   : 'zoom',
        #           showDuration : 250,
        #           hideMethod   : 'fade',
        #           hideDuration : 250
        #         })

        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'order'
        #         drink_id:@_id
        #     $('body').toast({
        #         title: "#{@title} added to cart."
        #         # message: 'Please see desk staff for key.'
        #         class : 'green'
        #         # position:'top center'
        #         # className:
        #         #     toast: 'ui massive message'
        #         displayTime: 5000
        #         transition:
        #           showMethod   : 'zoom',
        #           showDuration : 250,
        #           hideMethod   : 'fade',
        #           hideDuration : 250
        #         })

        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'

        'click .buy_drink': (e,t)->
            drink = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    order_type:'drink'
                    drink_id:drink._id
                    drink_title:drink.title
                    drink_price:drink.dollar_price
                    drink_image_id:drink.image_id
                    drink_point_price:drink.point_price
                    drink_dollar_price:drink.dollar_price
            Router.go "/order/#{new_order_id}/checkout"
            
        'click .rent_drink': (e,t)->
            drink = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    order_type:'rental'
                    drink_id:drink._id
                    drink_title:drink.title
                    drink_image_id:drink.image_id
                    drink_daily_rate:drink.daily_rate
                    drink_hourly_rate:drink.hourly_rate
                    
            Router.go "/order/#{new_order_id}/checkout"
            
            
# if Meteor.isClient
#     Template.user_drink.onCreated ->
#         @autorun => Meteor.subscribe 'user_drink', Router.current().params.username
#     Template.user_drink.events
#         'click .add_drink': ->
#             new_id =
#                 Docs.insert
#                     model:'drink'
#             Router.go "/drink/#{new_id}/edit"

#     Template.user_drink.helpers
#         drink: ->
#             current_user = Meteor.users.findOne username:Router.current().params.username
#             Docs.find {
#                 model:'drink'
#                 _author_id: current_user._id
#             }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'drink', (username)->
        # user = Meteor.users.findOne username:username
        Docs.find
            model:'drink'
            # _author_id: user._id
            app:'bc'
            
    Meteor.publish 'user_drink', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'drink'
            _author_id: user._id
            
    Meteor.publish 'drink_orders', (doc_id)->
        drink = Docs.findOne doc_id
        Docs.find
            model:'order'
            product_id:drink._id
            