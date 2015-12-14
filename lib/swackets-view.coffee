{CompositeDisposable} = require 'atom'

module.exports =
class SwacketsView

    intervalID = null

    constructor: ->
        @sweatify()

        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.workspace.onDidChangeActivePaneItem =>
            @sweatify()
            editor = atom.workspace.getActiveTextEditor()
            return unless editor
            @subscriptions.add editor.onDidChange(@sweatify)

        intervalID = setInterval =>
            @sweatify()
        , 140 #onScroll better in some cases, worse when scrolling

        editor = atom.workspace.getActiveTextEditor()
        return unless editor
        @subscriptions.add editor.onDidChange(@sweatify)

    destroy: ->
        clearInterval(intervalID)
        @subscriptions.dispose()

    sweatify: ->
        if (atom.config.get('swackets.syntax') == 'Brackets')
            openSyntax = '{'
            closeSyntax = '}'
            regex = /^.*?([\{\}]+)$/
        else
            openSyntax = '('
            closeSyntax = ')'
            regex = /^.*?([\(\)]+)$/

        setTimeout ->
            lines = document.querySelector("atom-text-editor.is-focused::shadow .lines")
            return if !lines
            lines.style.display = 'none'

            openBrackets = 0

            spans = document.querySelectorAll("atom-text-editor.is-focused::shadow .lines span")

            for span in spans
              match = span.innerHTML.match(regex)
              if match and span.className.indexOf('comment') < 0
                color = openBrackets
                if match[1] == openSyntax
                  openBrackets++
                  if openBrackets > 11
                    openBrackets = 0
                else if match[1] == closeSyntax
                  openBrackets--
                  if openBrackets < 0
                    openBrackets = 11
                  color = openBrackets

                className = ' swackets-' + color
                span.className = span.className.replace(/( swackets-\d+|$)/, className)

            lines.style.display = ''
        , 16
