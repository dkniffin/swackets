{CompositeDisposable} = require "atom"
SwacketsView = require './swackets-view'

module.exports =

  areaView: null

  activate: (state) ->
    @areaView = new SwacketsView()

  deactivate: ->
    @areaView.destroy()

  toggle: ->
    if @areaView.disabled
      @areaView.enable()
    else
      @areaView.disable()
