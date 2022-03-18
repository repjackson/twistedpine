if Meteor.isClient
    Router.route '/ingredients', (->
        @layout 'layout'
        @render 'ingredients'
        ), name:'ingredients'






if Meteor.isClient
    Router.route '/ingredient/:doc_id/', (->
        @layout 'layout'
        @render 'ingredient_view'
        ), name:'ingredient_view'
    Router.route '/ingredient/:doc_id/edit', (->
        @layout 'layout'
        @render 'ingredient_edit'
        ), name:'ingredient_edit'


    
    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.ingredient_edit.events
        'click .delete_ingredient_item': ->
            if confirm 'delete ingredient?'
                Docs.remove @_id
                Router.go "/ingredients"

    Template.ingredient_view.helpers
        sold_out: -> @inventory < 1
    Template.ingredient_view.events
        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'cart_item'
        #         ingredient_id:@_id
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
        #         ingredient_id:@_id
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

        'click .buy_ingredient': (e,t)->
            ingredient = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    order_type:'ingredient'
                    ingredient_id:ingredient._id
                    ingredient_title:ingredient.title
                    ingredient_price:ingredient.dollar_price
                    ingredient_image_id:ingredient.image_id
                    ingredient_point_price:ingredient.point_price
                    ingredient_dollar_price:ingredient.dollar_price
            Router.go "/order/#{new_order_id}/checkout"
            
        'click .rent_ingredient': (e,t)->
            ingredient = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    order_type:'rental'
                    ingredient_id:ingredient._id
                    ingredient_title:ingredient.title
                    ingredient_image_id:ingredient.image_id
                    ingredient_daily_rate:ingredient.daily_rate
                    ingredient_hourly_rate:ingredient.hourly_rate
                    
            Router.go "/order/#{new_order_id}/checkout"
            