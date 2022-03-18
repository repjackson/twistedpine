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
        @autorun => @subscribe 'drinks', ->
        Session.setDefault 'query', null
            
    Template.food.events 
        'keyup .search_food': (e,t)->
            # if e.which is 13
            query = t.$('.search_food').val()
            console.log query
            Session.set('query', query)
        'click .add_food': ->
            new_id = 
                Docs.insert 
                    model:'food'
            Router.go "/food/#{new_id}/edit"
            
        'click .add_drink': ->
            new_id = 
                Docs.insert 
                    model:'drink'
            Router.go "/drink/#{new_id}/edit"
        'click .clear_query': ->
            Session.set('query',null)
            
    Template.food.helpers
        drink_docs: ->
            match = {model:'drink'}
            if Session.get('query') 
                match.title = {$regex:"#{Session.get('query')}", $options:'i'}
            Docs.find match
        salad_docs: ->
            match = {model:'food',section:'salad'}
            if Session.get('query') 
                match.title = {$regex:"#{Session.get('query')}", $options:'i'}
            Docs.find match
            
        pizza_docs: ->
            match = {model:'food',section:'pizza'}
            if Session.get('query') 
                match.title = {$regex:"#{Session.get('query')}", $options:'i'}
            Docs.find match
            
        unfiltered_food: ->
            Docs.find 
                model:'food'
                section:$nin:['salad','pizza']
        other_food: ->
            Docs.find 
                model:'food'
                
        current_query: ->
            Session.get('query')
            
            
    Template.food_view.onCreated ->
        @autorun => @subscribe 'food_orders',Router.current().params.doc_id, ->
    
    
    Template.food_orders.helpers
        food_order_docs: ->
            Docs.find 
                model:'order'
                food_id:Router.current().params.doc_id


    Template.food_view.events
        'click .make': ->
            new_id = 
                Docs.insert 
                    model:'order'
                    food_id:Router.current().params.doc_id
                    product_id:Router.current().params.doc_id
                    order_type:'food'
            Router.go "/order/#{new_id}/edit"


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
            
    Meteor.publish 'drinks', (username)->
        # user = Meteor.users.findOne username:username
        Docs.find
            model:'drink'
            # _author_id: user._id
            
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
            
            
if Meteor.isClient
    Template.ingredient_picker.onCreated ->
        @autorun => @subscribe 'ingredient_search_results', Session.get('ingredient_search'), ->
        @autorun => @subscribe 'model_docs', 'ingredient', ->
    Template.ingredient_picker.helpers
        ingredient_results: ->
            Docs.find 
                model:'ingredient'
                title: {$regex:"#{Session.get('ingredient_search')}",$options:'i'}
                
        product_ingredients: ->
            product = Docs.findOne Router.current().params.doc_id
            Docs.find 
                # model:'ingredient'
                _id:$in:product.ingredient_ids
        ingredient_search_value: ->
            Session.get('ingredient_search')
        
    Template.ingredient_picker.events
        'click .clear_search': (e,t)->
            Session.set('ingredient_search', null)
            t.$('.ingredient_search').val('')

            
        'click .remove_ingredient': (e,t)->
            if confirm "remove #{@title} ingredient?"
                Docs.update Router.current().params.doc_id,
                    $pull:
                        ingredient_ids:@_id
                        ingredient_titles:@title
        'click .pick_ingredient': (e,t)->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    ingredient_ids:@_id
                    ingredient_titles:@title
            Session.set('ingredient_search',null)
            t.$('.ingredient_search').val('')
                    
        'keyup .ingredient_search': (e,t)->
            # if e.which is '13'
            val = t.$('.ingredient_search').val()
            console.log val
            Session.set('ingredient_search', val)

        'click .create_ingredient': ->
            new_id = 
                Docs.insert 
                    model:'ingredient'
                    title:Session.get('ingredient_search')
            Router.go "/ingredient/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'ingredient_search_results', (ingredient_title_queary)->
        Docs.find 
            model:'ingredient'
            title: {$regex:"#{ingredient_title_queary}",$options:'i'}
