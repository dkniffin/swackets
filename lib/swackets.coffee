{CompositeDisposable} = require "atom"
SwacketsView = require './swackets-view'

module.exports =

  areaView: null

  activate: (state) ->
    @areaView = new SwacketsView()

  deactivate: ->
    @areaView.destroy()
    @areaView = null

  toggle: ->
    #TODO toggle between underlining and swackets
