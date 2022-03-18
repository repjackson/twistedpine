if Meteor.isClient
    Router.route '/food', (->
        @layout 'layout'
        @render 'food'
        ), name:'food'

    Router.route '/', (->
        @layout 'layout'
        @render 'food'
        ), name:'home'


    Template.food.onCreated ->
        @autorun => @subscribe 'food', ->
            
    Template.food.events 
        'click .add_food': ->
            new_id = 
                Docs.insert 
                    model:'food'
            Router.go "/food/#{new_id}/edit"
            
    Template.food_view.onCreated ->
        @autorun => @subscribe 'food_orders',Router.current().params.doc_id, ->
    
    
    Template.food_orders.helpers
        food_order_docs: ->
            Docs.find 
                model:'order'
                food_id:Router.current().params.doc_id




if Meteor.isClient
    Router.route '/food/:doc_id/', (->
        @layout 'layout'
        @render 'food_view'
        ), name:'food_view'
    Router.route '/food/:doc_id/edit', (->
        @layout 'layout'
        @render 'food_edit'
        ), name:'food_edit'

    
    Template.food_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.food_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.food_edit.events
        'click .delete_food_item': ->
            if confirm 'delete food?'
                Docs.remove @_id
                Router.go "/food"

    Template.food.helpers
        burgers: ->
            Docs.find 
                model:'food'
                section:'burger'
        salads: ->
            Docs.find 
                model:'food'
                section:'salad'
        pizzas: ->
            Docs.find 
                model:'food'
                section:'pizza'
        unfiltered_food: ->
            Docs.find 
                model:'food'
                section:$nin:['salad','burger','pizza']
        ungrouped_food: ->
            Docs.find 
                model:'food'
    Template.food_view.helpers
        sold_out: -> @inventory < 1
        product_orders: ->
            Docs.find 
                model:'order'
                product_id:Router.current().params.doc_id
        
        
    Template.food_view.events
        'click .add_to_cart': ->
            new_id = 
                Docs.insert 
                    model:'cart_item'
                    product_id:@_id
                    status:'in_cart'
                
        'click .quick_buy': ->
            if confirm 'quick buy?'
                new_id = 
                    Docs.insert 
                        model:'order'
                        product_id:@_id
                
        
    Template.food_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
    Template.food_view.events
        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'cart_item'
        #         food_id:@_id
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
        #         food_id:@_id
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

        'click .buy_food': (e,t)->
            food = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    order_type:'food'
                    food_id:food._id
                    food_title:food.title
                    food_price:food.dollar_price
                    food_image_id:food.image_id
                    food_point_price:food.point_price
                    food_dollar_price:food.dollar_price
            Router.go "/order/#{new_order_id}/checkout"
            
        'click .rent_food': (e,t)->
            food = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    order_type:'rental'
                    food_id:food._id
                    food_title:food.title
                    food_image_id:food.image_id
                    food_daily_rate:food.daily_rate
                    food_hourly_rate:food.hourly_rate
                    
            Router.go "/order/#{new_order_id}/checkout"
            
            
# if Meteor.isClient
#     Template.user_food.onCreated ->
#         @autorun => Meteor.subscribe 'user_food', Router.current().params.username
#     Template.user_food.events
#         'click .add_food': ->
#             new_id =
#                 Docs.insert
#                     model:'food'
#             Router.go "/food/#{new_id}/edit"

#     Template.user_food.helpers
#         food: ->
#             current_user = Meteor.users.findOne username:Router.current().params.username
#             Docs.find {
#                 model:'food'
#                 _author_id: current_user._id
#             }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'food', (username)->
        # user = Meteor.users.findOne username:username
        Docs.find
            model:$in:['food','product']
            # _author_id: user._id
            app:'bc'
            
    Meteor.publish 'user_food', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'food'
            _author_id: user._id
            
    Meteor.publish 'food_orders', (doc_id)->
        food = Docs.findOne doc_id
        Docs.find
            model:'order'
            product_id:food._id
            