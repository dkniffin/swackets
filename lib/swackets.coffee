{CompositeDisposable} = require "atom"
SwacketsView = require './swackets-view'

module.exports =

  config:
    colors:
        title: 'Syntax Colours To Use:'
        default: ['#AAA', '#0F0', '#0FA', '#86F', '#F0F', '#93F']
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
