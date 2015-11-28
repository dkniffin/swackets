{Range, Point, CompositeDisposable} = require 'atom'
$ = require 'jquery'

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
        sweatyness = 0

        colors = ['#ff3333']
        colors = colors.concat(atom.config.get('swackets.colors'))
        curColor = colors.slice(0)

        colorsAlt = ['#ff3333']
        colorsAlt = colorsAlt.concat(atom.config.get('swackets.colors2'))
        open = false;
        shouldAlternateColor = false;
        even = false;


        if (atom.config.get('swackets.syntax') == 'Brackets')
            openSyntax = '{'
            closeSyntax = '}'
        else
            openSyntax = '('
            closeSyntax = ')'

        setTimeout ->

            lineGroups = $("atom-text-editor.is-focused::shadow .lines > div:not(.cursors) > div")
            numLineGroups = lineGroups.toArray().length
            firstGroup = undefined;

            while numLineGroups >= 0
                singleGroup = $(lineGroups).filter -> $(this).css('zIndex') == (''+numLineGroups)

                if (!firstGroup and singleGroup.length >= 1)
                    firstLine = $(singleGroup).children(".line").first().attr('data-screen-row')
                    secondLine = $(singleGroup).children(".line").eq(1).attr('data-screen-row') #1 is 2nd index

                    if (Number(secondLine) - Number(firstLine) != 1)
                        numLineGroups--
                        continue #Atom bug with DOM

                    range = new Range(new Point(0, 0), new Point(Number(firstLine), 0))
                    editor = atom.workspace.getActiveTextEditor()
                    return unless editor
                    northOfTheScroll = editor.getTextInBufferRange(range)
                    unseenLength = northOfTheScroll.length

                    curChar = 0
                    curSpeechChar = undefined #TODO omit comments and speechmarks (HARD)
                    while (curChar < unseenLength)

                        if (northOfTheScroll[curChar] == openSyntax)
                            sweatyness++
                        else if (northOfTheScroll[curChar] == closeSyntax)
                            sweatyness = Math.max.apply @, [(sweatyness-1), 0]

                        curChar++

                    firstGroup = true
                    ####DONE WITH PRE-BUFFER GUESSTIMATION####


                #Now color bracket spans:
                $(singleGroup).find('span').each (index, element) =>
                    len = $(element).html().length
                    if ($(element).html()[0] == openSyntax || $(element).html()[1] == openSyntax)
                        sweatyness++
                        sweatcap = Math.max.apply @, [sweatyness, 0]
                        sweatcap = Math.min.apply @, [sweatcap, curColor.length - 1]

                        $(element).css('color', curColor[sweatcap])
                        ##End of open brace colouring##


                    if ($(element).html()[0] == closeSyntax || $(element).html()[1] == closeSyntax)
                        sweatcap = Math.max.apply @, [sweatyness, 0]
                        sweatcap = Math.min.apply @, [sweatcap, curColor.length - 1]
                        $(element).css('color', curColor[sweatcap])

                        sweatyness = Math.max.apply @, [(sweatyness-1), 0]

                        if curColor[sweatcap] == colors[sweatcap]
                            curColor[sweatcap] = colorsAlt[sweatcap]
                        else
                            curColor[sweatcap] = colors[sweatcap]
                        ##End of close brace colouring##


                numLineGroups-- #END OF WHILE#
        , 16
