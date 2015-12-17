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
            lines = document.querySelector('atom-text-editor.is-focused::shadow .lines')
            return if !lines
            lines.style.display = 'none'

            openBrackets = 0

            lineGroups = document.querySelectorAll('atom-text-editor.is-focused::shadow .lines > div:not(.cursors) > div')

            sortedLineGroups = Array.prototype.sort.call lineGroups, (a, b) ->
              Math.min(1, Math.max(-1, a.style.zIndex - b.style.zIndex))

            Array.prototype.forEach.call sortedLineGroups, (lineGroup) ->
              spans = lineGroup.querySelectorAll('span:not(.comment)')

              Array.prototype.forEach.call spans, (span) ->
                match = span.innerHTML.match(regex)
                if match
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
