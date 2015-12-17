{CompositeDisposable} = require 'atom'

module.exports =
class SwacketsView

    intervalID = null
    openBrackets = 0
    config = {}

    constructor: ->
        @sweatifyTimeout()

        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.workspace.onDidChangeActivePaneItem =>
            @sweatifyTimeout()
            editor = atom.workspace.getActiveTextEditor()
            return unless editor
            @subscriptions.add editor.onDidChange(@sweatifyTimeout)

        intervalID = setInterval @sweatifyTimeout, 140 #onScroll better in some cases, worse when scrolling

        editor = atom.workspace.getActiveTextEditor()
        return unless editor
        @subscriptions.add editor.onDidChange(@sweatifyTimeout)

    destroy: ->
        clearInterval(intervalID)
        @subscriptions.dispose()

    config: ->
        if (atom.config.get('swackets.syntax') == 'Brackets')
            return {openSyntax: '{', closeSyntax: '}', regex: /^.*?([\{\}]+)$/}
        else
            return {openSyntax: '(', closeSyntax: ')', regex: /^.*?([\(\)]+)$/}

    sweatifyTimeout: =>
        setTimeout @sweatify, 16

    sweatify: =>
        lines = document.querySelector('atom-text-editor.is-focused::shadow .lines')
        return if !lines
        lines.style.display = 'none'
        openBrackets = 0
        config = @config()

        lineGroups = document.querySelectorAll('atom-text-editor.is-focused::shadow .lines > div:not(.cursors) > div')
        @sweatifyLineGroups(lineGroups)

        lines.style.display = ''

    sweatifyLineGroups: (lineGroups) ->
        sortedLineGroups = Array.prototype.sort.call lineGroups, (a, b) =>
            Math.min(1, Math.max(-1, a.style.zIndex - b.style.zIndex))

        Array.prototype.forEach.call sortedLineGroups, (lineGroup) =>
            spans = lineGroup.querySelectorAll('span:not(.comment)')
            @sweatifySpans(spans)

    sweatifySpans: (spans) ->
        {regex} = config

        Array.prototype.forEach.call spans, (span) =>
            match = span.innerHTML.match(regex)
            @sweatifySpan(span, match) if match

    sweatifySpan: (span, match) ->
        {openSyntax, closeSyntax} = config

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
