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


    
    Template.ingredients.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'ingredient', ->
    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.ingredient_edit.events
        'click .delete_ingredient_item': ->
            if confirm 'delete ingredient?'
                Docs.remove @_id
                Router.go "/ingredients"

    Template.ingredient_view.helpers
        sold_out: -> @inventory < 1
    Template.ingredient_view.events
        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'

            
    Template.ingredients.helpers
        ingredient_docs: ->
            match = {model:'ingredient'}
            # if Session.get('query') 
            #     match.title = {$regex:"#{Session.get('query')}", $options:'i'}
            Docs.find match


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
