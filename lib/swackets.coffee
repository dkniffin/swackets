{CompositeDisposable} = require "atom"
SwacketsView = require './swackets-view'

module.exports =

  config:
    colors:
        title: 'Syntax Colours To Use:'
        default: ['#ba8cb8', '#8ab7d8', '#60dd60', '#ffff70', '#ea9d70', '#e76464']
        type: 'array'
        items:
            type: 'string'

    colors2:
        title: 'Syntax Colours To Alternate:'
        description: '[**SIMILAR** colours to first set to differentiate equally nested syntax]'
        default: ['#ba8cb8', '#8ab7d8', '#60dd60', '#ffff70', '#ea9d70', '#e76464']
        type: 'array'
        items:
            type: 'string'

    syntax:
        title: 'Syntax To Colour:'
        type: 'string'
        default: 'Brackets'
        enum: ['Brackets', 'Parentheses']

  areaView: null

  activate: (state) ->
    @areaView = new SwacketsView()

  deactivate: ->
    @areaView.destroy()
    @areaView = null
