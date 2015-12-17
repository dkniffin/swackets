{Range, Point, CompositeDisposable} = require 'atom'

module.exports =
class SwacketsView

    intervalID = null
    openBrackets = 0
    config = {}
    totalColors = 11

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
        config = @config()

        lineGroups = @queryToArray document.querySelectorAll('atom-text-editor.is-focused::shadow .lines > div:not(.cursors) > div:not(.icon-right)')
        @sweatifyLineGroups(lineGroups)

        lines.style.display = ''

    queryToArray: (query) ->
        arr = []
        for item in query
            arr.push item
        arr

    sweatifyLineGroups: (lineGroups) ->
        sortedLineGroups = lineGroups.sort (a, b) =>
            Math.min(1, Math.max(-1, b.style.zIndex - a.style.zIndex))

        firstLine = sortedLineGroups[0].querySelector('.line')
        openBrackets = @openBracketsOffsetFor(+firstLine.getAttribute('data-screen-row'))

        sortedLineGroups.forEach (lineGroup) =>
            spans = lineGroup.querySelectorAll('span:not(.comment)')
            @sweatifySpans(spans)

    openBracketsOffsetFor: (lineNumber) ->
        {openSyntax, closeSyntax} = config

        range = new Range(new Point(0, 0), new Point(lineNumber, 0))
        editor = atom.workspace.getActiveTextEditor()
        return 0 unless editor
        text = editor.getTextInBufferRange(range)

        openBracketsOffset = 0
        openBracketsOffset += text.match(new RegExp('\\' + openSyntax, 'g'))?.length || 0
        openBracketsOffset -= text.match(new RegExp('\\' + closeSyntax, 'g'))?.length || 0

        return Math.max(0, openBracketsOffset % 11)

    sweatifySpans: (spans) ->
        {regex} = config

        for span in spans
            match = span.innerHTML.match(regex)
            @sweatifySpan(span, match) if match

    sweatifySpan: (span, match) ->
        {openSyntax, closeSyntax} = config

        color = openBrackets
        if match[1] == openSyntax
            openBrackets++
            if openBrackets > totalColors
                openBrackets = 0
        else if match[1] == closeSyntax
            openBrackets--
            if openBrackets < 0
                openBrackets = totalColors
            color = openBrackets
        className = ' swackets-' + color
        span.className = span.className.replace(/( swackets-\d+|$)/, className)
